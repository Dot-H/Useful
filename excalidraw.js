// Builds Excalidraw scenes and publishes them as shareable links,
// reproducing excalidraw-app's exportToBackend (compressData + AES-GCM).
const zlib = require("zlib");

const BACKEND = "https://json.excalidraw.com/api/v2/post/";

let seq = 0;
const nextId = () => `el${(seq++).toString(36).padStart(4, "0")}`;
const rand = () => Math.floor(Math.random() * 2 ** 31);

let indexCounter = 0;
const nextIndex = () => `a${(indexCounter++).toString(36).padStart(3, "0")}`;

const base = (over) => ({
  id: nextId(),
  x: 0,
  y: 0,
  width: 100,
  height: 100,
  angle: 0,
  strokeColor: "#1e1e1e",
  backgroundColor: "transparent",
  fillStyle: "solid",
  strokeWidth: 2,
  strokeStyle: "solid",
  roughness: 1,
  opacity: 100,
  groupIds: [],
  frameId: null,
  index: nextIndex(),
  roundness: null,
  seed: rand(),
  version: 1,
  versionNonce: rand(),
  isDeleted: false,
  boundElements: null,
  updated: Date.now(),
  link: null,
  locked: false,
  ...over,
});

const CHAR_W = 0.52;

function textEl({ x, y, text, size = 16, color = "#1e1e1e", align = "left", width, font = 5 }) {
  const lines = text.split("\n");
  const lineHeight = 1.25;
  const natural = Math.max(...lines.map((l) => l.length)) * size * CHAR_W;
  const w = width ?? natural;
  return base({
    type: "text",
    x,
    y,
    width: w,
    height: lines.length * size * lineHeight,
    strokeColor: color,
    text,
    originalText: text,
    fontSize: size,
    fontFamily: font,
    textAlign: align,
    verticalAlign: "top",
    containerId: null,
    lineHeight,
    autoResize: true,
  });
}

// A box with centered multi-line text laid on top of it.
function box({ x, y, w, h, label, bg = "transparent", size = 16, type = "rectangle", stroke = "#1e1e1e", strokeStyle = "solid", labelColor = "#1e1e1e" }) {
  const shape = base({
    type,
    x,
    y,
    width: w,
    height: h,
    backgroundColor: bg,
    strokeColor: stroke,
    strokeStyle,
    roundness: type === "rectangle" ? { type: 3 } : { type: 2 },
  });
  const out = [shape];
  if (label) {
    const lines = label.split("\n");
    const th = lines.length * size * 1.25;
    out.push(
      textEl({
        x,
        y: y + h / 2 - th / 2,
        text: label,
        size,
        align: "center",
        width: w,
        color: labelColor,
      })
    );
  }
  return out;
}

function arrow({ x1, y1, x2, y2, dashed = false, color = "#1e1e1e", bend = 0 }) {
  const pts = bend
    ? [[0, 0], [(x2 - x1) / 2, (y2 - y1) / 2 + bend], [x2 - x1, y2 - y1]]
    : [[0, 0], [x2 - x1, y2 - y1]];
  return base({
    type: "arrow",
    x: x1,
    y: y1,
    width: Math.abs(x2 - x1),
    height: Math.abs(y2 - y1),
    strokeColor: color,
    strokeStyle: dashed ? "dashed" : "solid",
    points: pts,
    lastCommittedPoint: null,
    startBinding: null,
    endBinding: null,
    startArrowhead: null,
    endArrowhead: "arrow",
    elbowed: false,
  });
}

// Multi-segment arrow through explicit waypoints.
function polyArrow({ pts, color = "#1e1e1e", dashed = false }) {
  const [x0, y0] = pts[0];
  const rel = pts.map(([x, y]) => [x - x0, y - y0]);
  const xs = rel.map((p) => p[0]);
  const ys = rel.map((p) => p[1]);
  return base({
    type: "arrow",
    x: x0,
    y: y0,
    width: Math.max(...xs) - Math.min(...xs),
    height: Math.max(...ys) - Math.min(...ys),
    strokeColor: color,
    strokeStyle: dashed ? "dashed" : "solid",
    points: rel,
    lastCommittedPoint: null,
    startBinding: null,
    endBinding: null,
    startArrowhead: null,
    endArrowhead: "arrow",
    elbowed: false,
  });
}

function line({ x1, y1, x2, y2, color = "#1e1e1e", dashed = false }) {
  return base({
    type: "line",
    x: x1,
    y: y1,
    width: Math.abs(x2 - x1),
    height: Math.abs(y2 - y1),
    strokeColor: color,
    strokeStyle: dashed ? "dashed" : "solid",
    points: [[0, 0], [x2 - x1, y2 - y1]],
    lastCommittedPoint: null,
    startArrowhead: null,
    endArrowhead: null,
  });
}

// ---- excalidraw-app exportToBackend ----------------------------------------

function concatBuffers(...buffers) {
  const total = 4 + 4 * buffers.length + buffers.reduce((a, b) => a + b.byteLength, 0);
  const out = Buffer.alloc(total);
  let cursor = 0;
  out.writeUInt32BE(1, cursor);
  cursor += 4;
  for (const b of buffers) {
    out.writeUInt32BE(b.byteLength, cursor);
    cursor += 4;
    Buffer.from(b).copy(out, cursor);
    cursor += b.byteLength;
  }
  return out;
}

async function publish(elements, name) {
  const scene = {
    type: "excalidraw",
    version: 2,
    source: "https://excalidraw.com",
    elements,
    appState: { gridSize: null, viewBackgroundColor: "#ffffff" },
    files: {},
  };

  const key = await crypto.subtle.generateKey({ name: "AES-GCM", length: 128 }, true, [
    "encrypt",
    "decrypt",
  ]);
  const jwk = await crypto.subtle.exportKey("jwk", key);

  const encodingMetadata = Buffer.from(
    JSON.stringify({ version: 2, compression: "pako@1", encryption: "AES-GCM" })
  );
  const contentsMetadata = Buffer.from(JSON.stringify(null));
  const data = Buffer.from(JSON.stringify(scene));

  const deflated = zlib.deflateSync(concatBuffers(contentsMetadata, data));
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encrypted = Buffer.from(
    await crypto.subtle.encrypt({ name: "AES-GCM", iv }, key, deflated)
  );

  const payload = concatBuffers(encodingMetadata, Buffer.from(iv), encrypted);

  const res = await fetch(BACKEND, { method: "POST", body: payload });
  const json = await res.json();
  if (!json.id) throw new Error(`${name}: ${JSON.stringify(json)}`);
  return `https://excalidraw.com/#json=${json.id},${jwk.k}`;
}

module.exports = { base, textEl, box, arrow, polyArrow, line, publish };
