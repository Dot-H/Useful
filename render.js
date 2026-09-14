// Renders a .excalidraw scene to SVG (rough.js paths, same hand-drawn look),
// then to PNG through headless Chrome.
const fs = require("fs");
const { execFileSync } = require("child_process");
const rough = require("roughjs");

const gen = rough.generator();
const PAD = 40;
const SCALE = 2;
const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const FONT = "Bradley Hand, Chalkboard SE, Comic Sans MS, cursive";

const esc = (s) =>
  s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function opsToPath(drawable) {
  const parts = [];
  for (const set of drawable.sets) {
    let d = "";
    for (const op of set.ops) {
      const p = op.data;
      if (op.op === "move") d += `M${p[0]} ${p[1]} `;
      else if (op.op === "bcurveTo") d += `C${p[0]} ${p[1]}, ${p[2]} ${p[3]}, ${p[4]} ${p[5]} `;
      else if (op.op === "lineTo") d += `L${p[0]} ${p[1]} `;
    }
    parts.push({ type: set.type, d: d.trim() });
  }
  return parts;
}

function drawableToSvg(drawable, el) {
  const o = drawable.options;
  return opsToPath(drawable)
    .map(({ type, d }) => {
      if (!d) return "";
      if (type === "fillPath" || type === "fillSketch") {
        const isSketch = type === "fillSketch";
        return `<path d="${d}" fill="${isSketch ? "none" : o.fill}" stroke="${
          isSketch ? o.fill : "none"
        }" stroke-width="${isSketch ? o.fillWeight : 0}"/>`;
      }
      const dash = o.strokeLineDash ? ` stroke-dasharray="${o.strokeLineDash.join(" ")}"` : "";
      return `<path d="${d}" fill="none" stroke="${o.stroke}" stroke-width="${o.strokeWidth}" stroke-linecap="round" stroke-linejoin="round"${dash}/>`;
    })
    .join("");
}

function roundedRectPath(w, h, r) {
  r = Math.min(r, w / 2, h / 2);
  return `M ${r} 0 L ${w - r} 0 Q ${w} 0 ${w} ${r} L ${w} ${h - r} Q ${w} ${h} ${w - r} ${h} L ${r} ${h} Q 0 ${h} 0 ${h - r} L 0 ${r} Q 0 0 ${r} 0 Z`;
}

function shapeOptions(el) {
  const filled = el.backgroundColor && el.backgroundColor !== "transparent";
  return {
    seed: el.seed,
    roughness: el.roughness,
    bowing: 1,
    stroke: el.strokeColor,
    strokeWidth: el.strokeWidth,
    strokeLineDash: el.strokeStyle === "dashed" ? [8, 8] : el.strokeStyle === "dotted" ? [1.5, 6] : undefined,
    fill: filled ? el.backgroundColor : undefined,
    fillStyle: "solid",
    disableMultiStroke: false,
    preserveVertices: false,
  };
}

function renderElement(el) {
  const t = (inner) => `<g transform="translate(${el.x} ${el.y})">${inner}</g>`;
  const opts = shapeOptions(el);

  if (el.type === "rectangle") {
    const radius = el.roundness ? Math.min(32, el.width * 0.25, el.height * 0.25) : 0;
    const d = radius
      ? gen.path(roundedRectPath(el.width, el.height, radius), opts)
      : gen.rectangle(0, 0, el.width, el.height, opts);
    return t(drawableToSvg(d, el));
  }
  if (el.type === "ellipse") {
    return t(
      drawableToSvg(
        gen.ellipse(el.width / 2, el.height / 2, el.width, el.height, opts),
        el
      )
    );
  }
  if (el.type === "diamond") {
    const pts = [
      [el.width / 2, 0],
      [el.width, el.height / 2],
      [el.width / 2, el.height],
      [0, el.height / 2],
    ];
    return t(drawableToSvg(gen.polygon(pts, opts), el));
  }
  if (el.type === "line" || el.type === "arrow") {
    const pts = el.points;
    let svg = drawableToSvg(gen.linearPath(pts, { ...opts, fill: undefined }), el);
    if (el.type === "arrow" && el.endArrowhead === "arrow") {
      const [px, py] = pts[pts.length - 2];
      const [x, y] = pts[pts.length - 1];
      const a = Math.atan2(y - py, x - px);
      const len = 18;
      const wings = [a + Math.PI * 0.85, a - Math.PI * 0.85].map(
        (ang) => `M ${x} ${y} L ${x + len * Math.cos(ang)} ${y + len * Math.sin(ang)}`
      );
      svg += `<path d="${wings.join(" ")}" fill="none" stroke="${el.strokeColor}" stroke-width="${el.strokeWidth}" stroke-linecap="round"/>`;
    }
    return t(svg);
  }
  if (el.type === "text") {
    const size = el.fontSize;
    const lh = size * el.lineHeight;
    const anchor = el.textAlign === "center" ? "middle" : el.textAlign === "right" ? "end" : "start";
    const dx = el.textAlign === "center" ? el.width / 2 : el.textAlign === "right" ? el.width : 0;
    return el.text
      .split("\n")
      .map(
        (l, i) =>
          `<text x="${el.x + dx}" y="${el.y + lh * i + size * 0.95}" font-family="${FONT}" font-size="${size}" fill="${el.strokeColor}" text-anchor="${anchor}" xml:space="preserve">${esc(l)}</text>`
      )
      .join("");
  }
  return "";
}

function bounds(elements) {
  let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
  for (const el of elements) {
    let w = el.width, h = el.height;
    if (el.type === "text") w = el.width;
    x0 = Math.min(x0, el.x);
    y0 = Math.min(y0, el.y);
    x1 = Math.max(x1, el.x + w);
    y1 = Math.max(y1, el.y + h);
  }
  return { x0, y0, x1, y1 };
}

function toSvg(scene) {
  const els = scene.elements.filter((e) => !e.isDeleted);
  const { x0, y0, x1, y1 } = bounds(els);
  const w = Math.ceil(x1 - x0 + PAD * 2);
  const h = Math.ceil(y1 - y0 + PAD * 2);
  const body = els.map(renderElement).join("\n");
  return {
    w,
    h,
    svg: `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
<rect width="${w}" height="${h}" fill="#ffffff"/>
<g transform="translate(${PAD - x0} ${PAD - y0})">
${body}
</g>
</svg>`,
  };
}

for (const name of process.argv.slice(2)) {
  const scene = JSON.parse(fs.readFileSync(`${name}.excalidraw`, "utf8"));
  const { w, h, svg } = toSvg(scene);
  fs.writeFileSync(`${name}.svg`, svg);
  fs.writeFileSync(
    `${name}.html`,
    `<html><head><style>html,body{margin:0;padding:0;background:#fff}</style></head><body>${svg}</body></html>`
  );
  execFileSync(CHROME, [
    "--headless",
    "--disable-gpu",
    "--hide-scrollbars",
    `--force-device-scale-factor=${SCALE}`,
    `--window-size=${w},${h}`,
    `--screenshot=${process.cwd()}/${name}.png`,
    `file://${process.cwd()}/${name}.html`,
  ], { stdio: "ignore" });
  console.log(`${name}.png  ${w}x${h} @${SCALE}x`);
}
