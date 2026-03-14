const fs = require('fs');
const path = require('path');

const projectRoot = process.cwd();
const scanRoots = [
  'lib/pages',
  'lib/widgets',
  'lib/features/onboarding/pages',
];

const ignoredPathParts = new Set([
  `${path.sep}lib${path.sep}l10n${path.sep}`,
  `${path.sep}lib${path.sep}data${path.sep}`,
  `${path.sep}assets${path.sep}data${path.sep}`,
]);

const allowedMarkers = [
  'localizedText(',
  '.strings.t(',
  'strings.t(',
  'context.strings.t(',
  'LessonContentLocalizer.',
  'LessonLocalizer.',
  'AlphabetContentLocalizer.',
  'GrammarText.',
  '_copy(',
  'appLanguage == AppLanguage.en',
  "english ? '",
];

const chinesePattern = /[\u4e00-\u9fff]/;
const mojibakePattern =
  /�|鍥涚甯歌瀛楀舰|涔﹀啓|鐙珛|璇嶉|璇嶅熬|鍩虹|鍚/;

function walk(dir, results) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if ([...ignoredPathParts].some((segment) => fullPath.includes(segment))) {
      continue;
    }
    if (entry.isDirectory()) {
      walk(fullPath, results);
      continue;
    }
    if (entry.isFile() && fullPath.endsWith('.dart')) {
      results.push(fullPath);
    }
  }
}

function isAllowed(lines, index) {
  const start = Math.max(0, index - 3);
  const end = Math.min(lines.length - 1, index + 1);
  for (let current = start; current <= end; current += 1) {
    if (allowedMarkers.some((marker) => lines[current].includes(marker))) {
      return true;
    }
  }
  return false;
}

const files = [];
for (const relativeRoot of scanRoots) {
  const fullRoot = path.join(projectRoot, relativeRoot);
  if (fs.existsSync(fullRoot)) {
    walk(fullRoot, files);
  }
}

const findings = [];

for (const file of files) {
  const content = fs.readFileSync(file, 'utf8');
  const lines = content.split(/\r?\n/);
  lines.forEach((line, index) => {
    if (!chinesePattern.test(line) && !mojibakePattern.test(line)) {
      return;
    }
    if (isAllowed(lines, index)) {
      return;
    }
    findings.push({
      file: path.relative(projectRoot, file).replace(/\\/g, '/'),
      line: index + 1,
      text: line.trim(),
    });
  });
}

const strictMode = process.argv.includes('--strict');

if (findings.length === 0) {
  console.log('No suspicious UI Chinese hardcodes found.');
  process.exit(0);
}

console.log('Potential UI Chinese hardcodes or mojibake found:');
for (const finding of findings) {
  console.log(`${finding.file}:${finding.line}: ${finding.text}`);
}

if (strictMode) {
  process.exit(1);
}

console.log(
  '\nReview the candidates above. Run with --strict to fail on any finding.',
);
process.exit(0);
