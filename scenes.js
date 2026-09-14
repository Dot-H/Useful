const fs = require("fs");
const { base, textEl, box, arrow, polyArrow, line, publish } = require("./excalidraw");

const GREEN = "#b2f2bb";
const RED = "#ffc9c9";
const BLUE = "#a5d8ff";
const YELLOW = "#ffec99";
const GREY = "#e9ecef";
const G_STROKE = "#2f9e44";
const R_STROKE = "#e03131";
const B_STROKE = "#1971c2";

// ---------------------------------------------------------------- diagram 1
function nodeField(ox, oy, filled, fill, stroke) {
  const els = [];
  const cols = 13, rows = 7, step = 33;
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const on = filled(c, r);
      els.push(
        base({
          type: "ellipse",
          x: ox + c * step,
          y: oy + r * step,
          width: 14,
          height: 14,
          backgroundColor: on ? fill : "transparent",
          strokeColor: on ? stroke : "#ced4da",
          strokeWidth: 1,
          roundness: { type: 2 },
        })
      );
    }
  }
  return els;
}

function diagram1() {
  const e = [];
  // left panel
  e.push(textEl({ x: 0, y: 0, text: "Whole-graph cache (today)", size: 22, width: 460, align: "center" }));
  e.push(...box({ x: 0, y: 45, w: 460, h: 275, bg: "transparent" }));
  e.push(...nodeField(25, 70, () => true, GREY, "#868e96"));
  e.push(...box({
    x: 0, y: 345, w: 460, h: 80, bg: RED, stroke: R_STROKE, size: 16,
    label: "Everything or nothing.\n90k - 205k nodes is over the cap: never cached.",
  }));

  // right panel
  const X = 560;
  e.push(textEl({ x: X, y: 0, text: "Partial cache", size: 22, width: 460, align: "center" }));
  e.push(...box({ x: X, y: 45, w: 460, h: 275, bg: "transparent" }));
  const hot = new Set(["4,2", "5,2", "5,3", "6,3", "6,2", "7,3", "6,4"]);
  e.push(...nodeField(X + 25, 70, (c, r) => hot.has(`${c},${r}`), GREEN, G_STROKE));
  e.push(
    base({
      type: "ellipse",
      x: X + 140, y: 125, width: 190, height: 145,
      backgroundColor: "transparent", strokeColor: G_STROKE, strokeStyle: "dashed", strokeWidth: 2,
      roundness: { type: 2 },
    })
  );
  e.push(textEl({ x: X + 120, y: 275, text: "what queries actually reach", size: 14, width: 230, align: "center", color: G_STROKE }));
  e.push(...box({
    x: X, y: 345, w: 460, h: 80, bg: GREEN, stroke: G_STROKE, size: 16,
    label: "Cached whatever the size.\nPer query: 3 nodes at p50, 347 at p99.",
  }));
  return e;
}

// ---------------------------------------------------------------- diagram 2
function diagram2() {
  const e = [];
  e.push(textEl({ x: 0, y: 0, text: "How the graph grows", size: 22, width: 1120, align: "center" }));

  // cached graph
  e.push(...box({ x: 0, y: 150, w: 200, h: 110, bg: YELLOW, label: "Cached graph\n(partial)", size: 17 }));

  // query
  e.push(...box({ x: 275, y: 60, w: 150, h: 60, bg: "transparent", label: "Query", size: 17 }));
  e.push(arrow({ x1: 350, y1: 120, x2: 350, y2: 150 }));

  // decision
  e.push(...box({ x: 250, y: 150, w: 200, h: 130, type: "diamond", bg: "transparent", label: "Covered by\nthe graph?", size: 15 }));
  e.push(line({ x1: 250, y1: 215, x2: 205, y2: 210, dashed: true, color: "#868e96" }));
  e.push(textEl({ x: 205, y: 222, text: "reads", size: 13, color: "#868e96" }));

  // hit
  e.push(arrow({ x1: 450, y1: 215, x2: 620, y2: 215 }));
  e.push(textEl({ x: 490, y: 182, text: "yes", size: 15, color: G_STROKE }));
  e.push(...box({ x: 620, y: 180, w: 240, h: 70, bg: GREEN, stroke: G_STROKE, label: "Answered from memory", size: 16 }));

  // miss
  e.push(arrow({ x1: 350, y1: 280, x2: 350, y2: 345 }));
  e.push(textEl({ x: 362, y: 295, text: "no", size: 15, color: B_STROKE }));
  e.push(...box({ x: 220, y: 345, w: 260, h: 80, bg: BLUE, stroke: B_STROKE, label: "The database answers\nthe very same query", size: 16 }));

  e.push(arrow({ x1: 480, y1: 370, x2: 620, y2: 330 }));
  e.push(...box({ x: 620, y: 300, w: 240, h: 60, bg: GREEN, stroke: G_STROKE, label: "Answer returned", size: 16 }));
  e.push(arrow({ x1: 480, y1: 400, x2: 620, y2: 440 }));
  e.push(...box({ x: 620, y: 410, w: 240, h: 90, bg: YELLOW, label: "Region: the nodes proved\nby that answer", size: 15 }));

  // growth back into the graph, routed clear of everything else
  e.push(polyArrow({
    pts: [[740, 500], [740, 560], [100, 560], [100, 265]],
    color: "#5f3dc4",
  }));
  e.push(textEl({ x: 260, y: 572, text: "the graph grows by exactly what was proved", size: 15, width: 420, align: "center", color: "#5f3dc4" }));

  // caps
  const capY = 660;
  e.push(textEl({ x: 0, y: capY - 40, text: "Bounds", size: 18 }));
  const caps = [
    "Region over 10k nodes:\nserved, not merged.\nA hub query must not\nevict the small regions.",
    "Graph over its node budget:\nreset to the incoming region\nrather than grown further.",
    "Query needing every node:\nwhole graph loaded, and it\nreplaces the partial one.",
  ];
  caps.forEach((c, i) => e.push(...box({ x: i * 380, y: capY, w: 350, h: 120, bg: GREY, label: c, size: 14 })));
  return e;
}

// ---------------------------------------------------------------- diagram 3
function diagram3() {
  const e = [];
  e.push(textEl({ x: 0, y: 0, text: "What makes a partial graph safe to read", size: 22, width: 1060, align: "center" }));

  e.push(textEl({
    x: 0, y: 55, size: 16, width: 1060, align: "center", color: "#495057",
    text: "An empty spot in a partial graph is ambiguous: nothing depends on it, or it was never loaded.\nThe graph therefore records what it holds completely, and every traversal checks it.",
  }));

  // covered zone
  e.push(base({
    type: "rectangle", x: 20, y: 160, width: 560, height: 200,
    backgroundColor: "#ebfbee", strokeColor: G_STROKE, strokeStyle: "dashed", roundness: { type: 3 },
  }));
  e.push(textEl({ x: 40, y: 175, text: "covered endpoints", size: 15, color: G_STROKE }));

  e.push(...box({ x: 70, y: 225, w: 180, h: 80, bg: GREEN, stroke: G_STROKE, label: "Revenue.amount", size: 15 }));
  e.push(arrow({ x1: 250, y1: 265, x2: 350, y2: 265 }));
  e.push(...box({ x: 350, y: 225, w: 180, h: 80, bg: GREEN, stroke: G_STROKE, label: "Margin.value", size: 15 }));

  e.push(arrow({ x1: 580, y1: 265, x2: 690, y2: 265, dashed: true, color: R_STROKE }));
  e.push(...box({
    x: 690, y: 215, w: 200, h: 100, bg: RED, stroke: R_STROKE, strokeStyle: "dashed",
    label: "Forecast.total\nnot claimed", size: 15,
  }));

  e.push(...box({
    x: 20, y: 395, w: 560, h: 85, bg: GREEN, stroke: G_STROKE, size: 15,
    label: "Traversal stays inside claimed endpoints:\nthe graph answers exactly what the database would.",
  }));
  e.push(...box({
    x: 620, y: 395, w: 440, h: 85, bg: RED, stroke: R_STROKE, size: 15,
    label: 'Traversal reaches an unclaimed one:\n"not loaded", never "no such node".',
  }));

  // claim kinds
  e.push(textEl({ x: 0, y: 530, text: "A claim is per column and per direction", size: 18 }));
  e.push(...box({
    x: 0, y: 575, w: 520, h: 95, bg: BLUE, stroke: B_STROKE, size: 15,
    label: "Source claim on (dataset, column):\nevery enabled node reading it is loaded.",
  }));
  e.push(...box({
    x: 545, y: 575, w: 515, h: 95, bg: BLUE, stroke: B_STROKE, size: 15,
    label: "Target claim on (dataset, column):\nevery enabled node writing it is loaded.",
  }));
  e.push(textEl({
    x: 0, y: 695, size: 15, width: 1060, align: "center", color: "#495057",
    text: "Claims are local: covering a column says nothing about the columns reachable from it.\nThat is what keeps a newly enabled node cheap to fold in, with no claim ever recomputed or retracted.",
  }));
  return e;
}

(async () => {
  const scenes = [["1-why", diagram1()], ["2-growth", diagram2()], ["3-coverage", diagram3()]];
  for (const [name, els] of scenes) {
    const scene = {
      type: "excalidraw",
      version: 2,
      source: "https://excalidraw.com",
      elements: els,
      appState: { gridSize: null, viewBackgroundColor: "#ffffff" },
      files: {},
    };
    fs.writeFileSync(`${name}.excalidraw`, JSON.stringify(scene, null, 2));
    if (process.env.PUBLISH === "1") {
      console.log(`${name}\t${await publish(els, name)}`);
    } else {
      console.log(`${name}\twrote ${name}.excalidraw (${els.length} elements)`);
    }
  }
})();
