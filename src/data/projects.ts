export type ProjectStatus = 'exploration' | 'case-study' | 'print-ready' | 'tooling';

export interface Project {
  slug: string;
  title: string;
  series: string;
  tagline: string;
  description: string;
  tags: string[];
  status: ProjectStatus;
  /** Path to a preview image inside the project folder (served at /files/<slug>/) */
  image?: string;
  /** Path to an interactive viewer inside the project folder (served at /files/<slug>/) */
  viewer?: string;
  /** Highlights shown as chips on the detail page */
  highlights?: string[];
}

export const STATUS_LABELS: Record<ProjectStatus, string> = {
  exploration: 'Field exploration',
  'case-study': 'Case study',
  'print-ready': 'Print ready',
  tooling: 'Tooling',
};

export const projects: Project[] = [
  {
    slug: 'pegboard-saddle-jig',
    title: 'FORM / FIELD',
    series: 'Pegboard drilling jigs',
    tagline: 'Five ways to build a precise grid.',
    description:
      'An interactive explorer comparing five jig concepts for drilling pegboard hole grids — leapfrog bar, row bridge, grid tile, indexed rail, and a convertible starter. Rotate the models, tune parameters, and step through each workflow.',
    tags: ['interactive', 'exploration', 'three.js'],
    status: 'exploration',
    viewer: 'index.html',
    highlights: ['5 jig concepts', 'live 3D viewer', 'parameter studies'],
  },
  {
    slug: 'pegboard-drilling-jigs',
    title: 'Drilling Jigs — v2',
    series: 'Pegboard drilling jigs',
    tagline: 'The clean-print edition.',
    description:
      'Parametric 3D-printable jigs for drilling 10 mm holes on a 50 mm grid into 18 mm plywood pegboard — corner base + fence, indexing bar, and row seeder. Sources in OpenSCAD and a Fusion 360 Python generator. Zero supports.',
    tags: ['openSCAD', 'fusion 360', 'print-ready'],
    status: 'print-ready',
    image: 'preview_assembly.png',
    highlights: ['4 printable parts', 'OpenSCAD + Fusion 360', 'no supports'],
  },
  {
    slug: 'pegboard-jigs-v3',
    title: 'Jig — v3',
    series: 'Pegboard drilling jigs',
    tagline: 'A configurable two-tool system.',
    description:
      'Corner starter drills a 2×2 seed; a four-pin indexing tile carries the grid forward. Every dimension — hole size, pitch, edge offset, tile layout, printer bed — is a parameter. Ships with a browser configurator and 3D viewer.',
    tags: ['openSCAD', 'parametric', 'interactive'],
    status: 'case-study',
    image: 'stl/preview_indexing_tile.png',
    viewer: 'index.html',
    highlights: ['browser configurator', 'A1 mini target', 'full case study'],
  },
  {
    slug: 'pegboard-print-set',
    title: 'A1 mini Print Set',
    series: 'Pegboard drilling jigs',
    tagline: 'Sliced and ready to print.',
    description:
      'Print-ready STLs and BambuStudio-sliced G-code for all five jig proposals — 11 parts, ~15 h total print time, no supports. Includes the flattened slicer profiles used, so you can re-slice or adapt to your machine.',
    tags: ['gcode', 'bambu a1 mini', 'print-ready'],
    status: 'print-ready',
    highlights: ['11 parts', 'sliced G-code included', 'slicer profiles'],
  },
];
