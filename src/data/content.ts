import { marked } from 'marked';

const readmes = import.meta.glob('../../public/files/*/README.md', {
  query: '?raw',
  import: 'default',
  eager: true,
}) as Record<string, string>;

const skillFiles = import.meta.glob('../../skills/*/SKILL.md', {
  query: '?raw',
  import: 'default',
  eager: true,
}) as Record<string, string>;

const CASE_STUDY = import.meta.glob('../../public/files/*/CASE_STUDY.md', {
  query: '?raw',
  import: 'default',
  eager: true,
}) as Record<string, string>;

function slugFor(key: string, marker: string): string | null {
  const i = key.indexOf(marker);
  if (i === -1) return null;
  const dir = key.slice(0, i).split('/').filter(Boolean).pop();
  return dir ?? null;
}

const bySlug = (map: Record<string, string>, marker: string) =>
  new Map(
    Object.entries(map)
      .map(([key, body]) => {
        const slug = slugFor(key, marker);
        return slug ? ([slug, body] as const) : null;
      })
      .filter((e): e is readonly [string, string] => e !== null),
  );

const readmeMap = bySlug(readmes, '/README.md');
const caseStudyMap = bySlug(CASE_STUDY, '/CASE_STUDY.md');
const skillMap = bySlug(skillFiles, '/SKILL.md');

export function getProjectMarkdown(slug: string): string | null {
  return readmeMap.get(slug) ?? null;
}

export function getCaseStudy(slug: string): string | null {
  return caseStudyMap.get(slug) ?? null;
}

export interface SkillSource {
  slug: string;
  raw: string;
}

export function getSkills(): SkillSource[] {
  return [...skillMap.entries()]
    .map(([slug, raw]) => ({ slug, raw }))
    .sort((a, b) => a.slug.localeCompare(b.slug));
}

export function getSkill(slug: string): SkillSource | null {
  const raw = skillMap.get(slug);
  return raw ? { slug, raw } : null;
}

export interface SkillMeta {
  slug: string;
  name?: string;
  description?: string;
}

export function getSkillMetas(): SkillMeta[] {
  return getSkills().map((s) => {
    const { data } = splitFrontmatter(s.raw);
    return { slug: s.slug, name: data.name, description: data.description };
  });
}

export function splitFrontmatter(raw: string): { data: Record<string, string>; body: string } {
  const m = raw.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (!m) return { data: {}, body: raw };
  const data: Record<string, string> = {};
  for (const line of m[1].split(/\r?\n/)) {
    const i = line.indexOf(':');
    if (i > 0) data[line.slice(0, i).trim()] = line.slice(i + 1).trim();
  }
  return { data, body: raw.slice(m[0].length) };
}

export function renderMarkdown(md: string): string {
  return marked.parse(md, { async: false }) as string;
}
