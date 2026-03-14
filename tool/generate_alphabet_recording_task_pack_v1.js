const fs = require('fs');
const path = require('path');
const cp = require('child_process');

const projectRoot = process.cwd();
const outputRoot = path.join(
  projectRoot,
  'docs',
  'recording_task_packages',
  '字母首批录音任务包_V1',
);
const manifestPath = path.join(projectRoot, 'assets', 'data', 'audio_manifest.json');
const alphabetSourcePath = path.join(
  projectRoot,
  'lib',
  'data',
  'sample_alphabet_data.dart',
);

const packageDefinitions = [
  {
    id: '01_letter_names',
    title: '字母名称',
    placeholderFile: '录音文件放这里.txt',
  },
  {
    id: '02_letter_sounds',
    title: '字母基础发音',
    placeholderFile: '录音文件放这里.txt',
  },
  {
    id: '03_letter_examples_basic',
    title: '基础示例词',
    placeholderFile: '录音文件放这里.txt',
  },
];

const diacritizedLetterNames = {
  'ا': 'أَلِف',
  'ب': 'بَاء',
  'ت': 'تَاء',
  'ث': 'ثَاء',
  'ج': 'جِيم',
  'ح': 'حَاء',
  'خ': 'خَاء',
  'د': 'دَال',
  'ذ': 'ذَال',
  'ر': 'رَاء',
  'ز': 'زَاي',
  'س': 'سِين',
  'ش': 'شِين',
  'ص': 'صَاد',
  'ض': 'ضَاد',
  'ط': 'طَاء',
  'ظ': 'ظَاء',
  'ع': 'عَيْن',
  'غ': 'غَيْن',
  'ف': 'فَاء',
  'ق': 'قَاف',
  'ك': 'كَاف',
  'ل': 'لَام',
  'م': 'مِيم',
  'ن': 'نُون',
  'ه': 'هَاء',
  'و': 'وَاو',
  'ي': 'يَاء',
};

main();

function main() {
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  const alphabetNames = parseAlphabetNames(
    fs.readFileSync(alphabetSourcePath, 'utf8'),
  );

  const letterItems = sortBySourceId(
    manifest.items.filter(
      (item) =>
        item.sourceType === 'alphabet_letter' && item.speed === 'normal',
    ),
  );
  const pronunciationItems = sortBySourceId(
    manifest.items.filter(
      (item) =>
        item.sourceType === 'alphabet_pronunciation' && item.speed === 'normal',
    ),
  );
  const exampleItems = sortBySourceId(
    manifest.items.filter(
      (item) =>
        item.sourceType === 'alphabet_example_word' && item.speed === 'normal',
    ),
  );

  if (letterItems.length !== 28) {
    throw new Error(`Expected 28 alphabet letter items, got ${letterItems.length}.`);
  }

  if (pronunciationItems.length !== 364) {
    throw new Error(
      `Expected 364 alphabet pronunciation items, got ${pronunciationItems.length}.`,
    );
  }

  if (exampleItems.length !== 28) {
    throw new Error(`Expected 28 alphabet example items, got ${exampleItems.length}.`);
  }

  const basicSoundItems = pronunciationItems.filter((_, index) => index % 13 === 0);

  if (basicSoundItems.length !== 28) {
    throw new Error(`Expected 28 basic sound items, got ${basicSoundItems.length}.`);
  }

  const nameTasks = buildLetterNameTasks(letterItems, alphabetNames);
  const soundTasks = buildLetterSoundTasks(letterItems, basicSoundItems, alphabetNames);
  const exampleTasks = buildExampleTasks(letterItems, exampleItems, alphabetNames);
  const allTasks = [...nameTasks, ...soundTasks, ...exampleTasks];

  fs.rmSync(outputRoot, { recursive: true, force: true });
  ensureDir(outputRoot);

  for (const packageDefinition of packageDefinitions) {
    const packageDir = path.join(outputRoot, packageDefinition.id);
    ensureDir(packageDir);
    writeText(
      path.join(packageDir, packageDefinition.placeholderFile),
      buildPackagePlaceholder(packageDefinition, allTasks),
    );
  }

  writeText(
    path.join(outputRoot, '目录结构说明.md'),
    buildDirectoryGuide(allTasks),
  );

  createTaskSheet(
    path.join(outputRoot, 'task_sheet.xlsx'),
    allTasks,
  );

  createReadmeDocx(
    path.join(outputRoot, 'readme_录音说明.docx'),
    buildReadmeParagraphs(allTasks),
  );

  const summary = {
    generatedAt: new Date().toISOString(),
    outputRoot,
    packages: packageDefinitions.map((packageDefinition) => ({
      id: packageDefinition.id,
      count: allTasks.filter((task) => task.packageName === packageDefinition.id).length,
    })),
    total: allTasks.length,
  };

  writeText(
    path.join(outputRoot, '任务包摘要.json'),
    `${JSON.stringify(summary, null, 2)}\n`,
  );

  process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
}

function buildLetterNameTasks(letterItems, alphabetNames) {
  return letterItems.map((letterItem, index) => {
    const alphabetMeta = alphabetNames.get(letterItem.textAr);
    if (!alphabetMeta) {
      throw new Error(`Missing alphabet name data for letter "${letterItem.textAr}".`);
    }

    const vocalizedName =
      diacritizedLetterNames[letterItem.textAr] ?? alphabetMeta.arabicName;

    return {
      sequence: index + 1,
      fileName: letterItem.fileName,
      packageName: '01_letter_names',
      type: '字母名称',
      arabicText: alphabetMeta.arabicName,
      vocalizedText: vocalizedName,
      chineseNote: `读出字母 ${letterItem.textAr} 的名称“${vocalizedName}”。不要读成基础发音。`,
      recordingRequirement:
        'teaching_clear / normal；只读字母名称 1 次；起音和收尾干净；不要加解释。',
      completionStatus: '待录音',
      issueFeedback: '',
    };
  });
}

function buildLetterSoundTasks(letterItems, basicSoundItems, alphabetNames) {
  return basicSoundItems.map((soundItem, index) => {
    const letterItem = letterItems[index];
    const alphabetMeta = alphabetNames.get(letterItem.textAr);

    if (!alphabetMeta) {
      throw new Error(`Missing alphabet name data for letter "${letterItem.textAr}".`);
    }

    return {
      sequence: letterItems.length + index + 1,
      fileName: soundItem.fileName,
      packageName: '02_letter_sounds',
      type: '字母基础发音',
      arabicText: soundItem.textPlain,
      vocalizedText: soundItem.textAr,
      chineseNote: `读出字母 ${letterItem.textAr} 的基础音“${soundItem.textAr}”。不要读字母名称“${alphabetMeta.arabicName}”。`,
      recordingRequirement:
        'teaching_clear / normal；只读基础音 1 次；不要拖长；不要读成字母名称。',
      completionStatus: '待录音',
      issueFeedback: '',
    };
  });
}

function buildExampleTasks(letterItems, exampleItems, alphabetNames) {
  return exampleItems.map((exampleItem, index) => {
    const letterItem = letterItems[index];
    const alphabetMeta = alphabetNames.get(letterItem.textAr);

    if (!alphabetMeta) {
      throw new Error(`Missing alphabet name data for letter "${letterItem.textAr}".`);
    }

    return {
      sequence: letterItems.length * 2 + index + 1,
      fileName: exampleItem.fileName,
      packageName: '03_letter_examples_basic',
      type: '基础示例词',
      arabicText: exampleItem.textPlain,
      vocalizedText: exampleItem.textAr,
      chineseNote: `读出字母 ${letterItem.textAr} 的基础示例词“${exampleItem.textAr}”（${exampleItem.textZh}）。整词自然读出，不要拆读。`,
      recordingRequirement:
        'teaching_clear / normal；整词完整读 1 次；不要拼字母；不要翻译；尾音自然收干净。',
      completionStatus: '待录音',
      issueFeedback: '',
    };
  });
}

function parseAlphabetNames(source) {
  const nameMap = new Map();
  const pattern =
    /'([^']+)'\s*:\s*_AlphabetNameData\(arabicName:\s*'([^']+)',\s*latinName:\s*(?:'([^']+)'|"([^"]+)"),?\)/g;

  for (const match of source.matchAll(pattern)) {
    nameMap.set(match[1], {
      letter: match[1],
      arabicName: match[2],
      latinName: match[3] || match[4],
    });
  }

  if (nameMap.size !== 28) {
    throw new Error(`Expected 28 alphabet names, got ${nameMap.size}.`);
  }

  return nameMap;
}

function sortBySourceId(items) {
  return [...items].sort((left, right) => {
    const leftNumber = extractTrailingNumber(left.sourceId);
    const rightNumber = extractTrailingNumber(right.sourceId);
    return leftNumber - rightNumber;
  });
}

function extractTrailingNumber(value) {
  const match = /(\d+)$/.exec(value);
  if (!match) {
    throw new Error(`Cannot extract trailing number from "${value}".`);
  }

  return Number(match[1]);
}

function buildPackagePlaceholder(packageDefinition, tasks) {
  const packageTasks = tasks.filter((task) => task.packageName === packageDefinition.id);
  const sampleNames = packageTasks
    .slice(0, 5)
    .map((task) => `- ${task.fileName}`)
    .join('\n');

  return [
    `本目录用于 ${packageDefinition.id}（${packageDefinition.title}）。`,
    `条目数：${packageTasks.length}`,
    '请将该包录好的 mp3 直接保存到本目录。',
    '文件名以根目录 task_sheet.xlsx 为准，不要自行改名。',
    '统一录音版本：teaching_clear / normal',
    '',
    '示例文件名：',
    sampleNames,
    '',
    '完整清单请查看根目录 task_sheet.xlsx。',
    '',
  ].join('\n');
}

function buildDirectoryGuide(tasks) {
  const counts = countTasksByPackage(tasks);

  return [
    '# 字母首批录音任务包 V1',
    '',
    '## 目录结构',
    '',
    '```text',
    '字母首批录音任务包_V1/',
    '  task_sheet.xlsx',
    '  readme_录音说明.docx',
    '  目录结构说明.md',
    '  任务包摘要.json',
    '  01_letter_names/',
    '    录音文件放这里.txt',
    '  02_letter_sounds/',
    '    录音文件放这里.txt',
    '  03_letter_examples_basic/',
    '    录音文件放这里.txt',
    '```',
    '',
    '## 包别说明',
    '',
    `- \`01_letter_names\`：${counts['01_letter_names']} 条，录 28 个字母名称。`,
    `- \`02_letter_sounds\`：${counts['02_letter_sounds']} 条，录 28 个字母基础发音。`,
    `- \`03_letter_examples_basic\`：${counts['03_letter_examples_basic']} 条，录 28 个字母基础示例词。`,
    `- 总计：${tasks.length} 条。`,
    '',
    '## 命名说明',
    '',
    '- 所有文件名都已经在 `task_sheet.xlsx` 中生成，专家只需按文件名保存。',
    '- `02_letter_sounds` 的文件名不是连续编号，这是为了直接对齐 App 当前的基础发音资源位，便于首批接入验证。',
    '- `01_letter_names` 对应现有 `alpha_l_***_normal.mp3` 资源位。',
    '- `02_letter_sounds` 对应现有 `alpha_p_***_normal.mp3` 基础发音资源位。',
    '- `03_letter_examples_basic` 对应现有 `alpha_w_***_normal.mp3` 资源位。',
    '',
    '## 使用方式',
    '',
    '- 录音专家根据 `task_sheet.xlsx` 逐条录音。',
    '- 每个 mp3 直接保存到对应包目录中。',
    '- 完成后在 `task_sheet.xlsx` 更新“完成状态”和“问题反馈”两列。',
    '',
  ].join('\n');
}

function buildReadmeParagraphs(tasks) {
  const counts = countTasksByPackage(tasks);
  return [
    '字母首批录音任务包 V1',
    `生成日期：${new Date().toISOString().slice(0, 10)}`,
    '用途：用于先验证配音专家录音效果和 App 接入效果，本次只覆盖字母模块。',
    `本包共 ${tasks.length} 条任务，分为 3 个分包。`,
    `01_letter_names：${counts['01_letter_names']} 条，录字母名称。`,
    `02_letter_sounds：${counts['02_letter_sounds']} 条，录字母基础发音。`,
    `03_letter_examples_basic：${counts['03_letter_examples_basic']} 条，录字母基础示例词。`,
    '统一录音版本：teaching_clear',
    '统一语速：normal',
    '输出格式建议：mp3，mono，24kHz，48kbps。若录音棚模板固定，至少保证所有文件参数一致。',
    '通用录音要求：',
    '1. 使用现代标准阿拉伯语教学口吻，清晰、稳定、自然，不要过度表演。',
    '2. 每条只读 1 次，不加中文、不加解释、不加额外寒暄。',
    '3. 起音利落，结尾收干净，避免明显呼吸声、爆破音和长时间空白。',
    '4. 如某条文本发音、口型或内容存在疑问，请先在 task_sheet.xlsx 的“问题反馈”列标注，再统一回传。',
    '按包说明：',
    '01_letter_names：只读字母名称，例如“بَاء”；不要读成基础音。',
    '02_letter_sounds：只读字母基础音，例如“بَ”；不要读成字母名称“بَاء”。',
    '03_letter_examples_basic：整词自然读出，例如“بَيْت”；不要拆字母，不要翻译。',
    '文件保存规则：',
    '1. 严格使用 task_sheet.xlsx 中给出的文件名保存，不要自行重命名。',
    '2. 每个 mp3 直接放入对应包目录。',
    '3. 录音完成后，请同步更新 task_sheet.xlsx 中的“完成状态”和“问题反馈”。',
    '目录提醒：',
    '01_letter_names、02_letter_sounds、03_letter_examples_basic 三个目录就是交付目录。',
    '特别说明：02_letter_sounds 的文件名不是连续编号，这是为了直接对齐 App 当前的基础发音资源位，方便首批接入验证。',
    '交付前自查：',
    '1. 文件名是否与 task_sheet.xlsx 完全一致。',
    '2. 文件是否都放进了正确的包目录。',
    '3. 声音风格是否统一为 teaching_clear，语速是否保持 normal。',
    '4. 是否存在漏录、重录、底噪、削波或尾部多余空白。',
  ];
}

function countTasksByPackage(tasks) {
  return tasks.reduce((result, task) => {
    result[task.packageName] = (result[task.packageName] || 0) + 1;
    return result;
  }, {});
}

function createTaskSheet(outputFile, tasks) {
  const headers = [
    '序号',
    '文件名',
    '包名',
    '类型',
    '阿语文本',
    '带音符文本',
    '中文说明',
    '录音要求',
    '完成状态',
    '问题反馈',
  ];

  const rows = [headers];
  for (const task of tasks) {
    rows.push([
      String(task.sequence),
      task.fileName,
      task.packageName,
      task.type,
      task.arabicText,
      task.vocalizedText,
      task.chineseNote,
      task.recordingRequirement,
      task.completionStatus,
      task.issueFeedback,
    ]);
  }

  const tempRoot = path.join(outputRoot, '.tmp_task_sheet');
  fs.rmSync(tempRoot, { recursive: true, force: true });

  const workbookDir = path.join(tempRoot, 'xl');
  const worksheetDir = path.join(workbookDir, 'worksheets');
  const workbookRelDir = path.join(workbookDir, '_rels');
  const relDir = path.join(tempRoot, '_rels');
  const docPropsDir = path.join(tempRoot, 'docProps');

  ensureDir(worksheetDir);
  ensureDir(workbookRelDir);
  ensureDir(relDir);
  ensureDir(docPropsDir);

  writeText(path.join(tempRoot, '[Content_Types].xml'), buildXlsxContentTypesXml());
  writeText(path.join(relDir, '.rels'), buildXlsxRootRelsXml());
  writeText(path.join(docPropsDir, 'app.xml'), buildAppPropsXml('task_sheet'));
  writeText(path.join(docPropsDir, 'core.xml'), buildCorePropsXml('字母首批录音任务包 V1 Task Sheet'));
  writeText(path.join(workbookDir, 'workbook.xml'), buildWorkbookXml('录音任务'));
  writeText(
    path.join(workbookRelDir, 'workbook.xml.rels'),
    buildWorkbookRelsXml(),
  );
  writeText(path.join(workbookDir, 'styles.xml'), buildStylesXml());
  writeText(
    path.join(worksheetDir, 'sheet1.xml'),
    buildWorksheetXml(rows),
  );

  zipDirectory(tempRoot, outputFile);
  fs.rmSync(tempRoot, { recursive: true, force: true });
}

function createReadmeDocx(outputFile, paragraphs) {
  const tempRoot = path.join(outputRoot, '.tmp_readme_docx');
  fs.rmSync(tempRoot, { recursive: true, force: true });

  const relDir = path.join(tempRoot, '_rels');
  const wordDir = path.join(tempRoot, 'word');
  const docPropsDir = path.join(tempRoot, 'docProps');

  ensureDir(relDir);
  ensureDir(wordDir);
  ensureDir(docPropsDir);

  writeText(path.join(tempRoot, '[Content_Types].xml'), buildDocxContentTypesXml());
  writeText(path.join(relDir, '.rels'), buildDocxRootRelsXml());
  writeText(path.join(docPropsDir, 'app.xml'), buildAppPropsXml('readme_录音说明'));
  writeText(path.join(docPropsDir, 'core.xml'), buildCorePropsXml('字母首批录音任务包 V1 Readme'));
  writeText(path.join(wordDir, 'document.xml'), buildDocxDocumentXml(paragraphs));

  zipDirectory(tempRoot, outputFile);
  fs.rmSync(tempRoot, { recursive: true, force: true });
}

function buildWorksheetXml(rows) {
  const rowXml = rows
    .map((row, rowIndex) => buildWorksheetRowXml(row, rowIndex + 1))
    .join('');

  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheetViews>
    <sheetView workbookViewId="0"/>
  </sheetViews>
  <sheetFormatPr defaultRowHeight="18"/>
  <cols>
    <col min="1" max="1" width="8" customWidth="1"/>
    <col min="2" max="2" width="24" customWidth="1"/>
    <col min="3" max="3" width="22" customWidth="1"/>
    <col min="4" max="4" width="18" customWidth="1"/>
    <col min="5" max="5" width="18" customWidth="1"/>
    <col min="6" max="6" width="20" customWidth="1"/>
    <col min="7" max="7" width="52" customWidth="1"/>
    <col min="8" max="8" width="56" customWidth="1"/>
    <col min="9" max="9" width="14" customWidth="1"/>
    <col min="10" max="10" width="18" customWidth="1"/>
  </cols>
  <sheetData>${rowXml}</sheetData>
</worksheet>
`;
}

function buildWorksheetRowXml(row, rowNumber) {
  const cellXml = row
    .map((value, columnIndex) => buildCellXml(rowNumber, columnIndex, value))
    .join('');
  return `<row r="${rowNumber}">${cellXml}</row>`;
}

function buildCellXml(rowNumber, columnIndex, value) {
  const cellRef = `${columnNumberToName(columnIndex + 1)}${rowNumber}`;
  const isNumeric = columnIndex === 0 && rowNumber > 1;
  if (isNumeric) {
    return `<c r="${cellRef}"><v>${xmlEscape(String(value))}</v></c>`;
  }

  return `<c r="${cellRef}" t="inlineStr"><is><t xml:space="preserve">${xmlEscape(String(value ?? ''))}</t></is></c>`;
}

function columnNumberToName(columnNumber) {
  let value = columnNumber;
  let name = '';
  while (value > 0) {
    const remainder = (value - 1) % 26;
    name = String.fromCharCode(65 + remainder) + name;
    value = Math.floor((value - 1) / 26);
  }
  return name;
}

function buildWorkbookXml(sheetName) {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="${xmlEscape(sheetName)}" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>
`;
}

function buildWorkbookRelsXml() {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
`;
}

function buildStylesXml() {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="1">
    <font>
      <sz val="11"/>
      <name val="Calibri"/>
      <family val="2"/>
    </font>
  </fonts>
  <fills count="2">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
  </fills>
  <borders count="1">
    <border>
      <left/>
      <right/>
      <top/>
      <bottom/>
      <diagonal/>
    </border>
  </borders>
  <cellStyleXfs count="1">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0"/>
  </cellStyleXfs>
  <cellXfs count="1">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
  </cellXfs>
  <cellStyles count="1">
    <cellStyle name="Normal" xfId="0" builtinId="0"/>
  </cellStyles>
</styleSheet>
`;
}

function buildXlsxContentTypesXml() {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
`;
}

function buildXlsxRootRelsXml() {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
`;
}

function buildDocxContentTypesXml() {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
`;
}

function buildDocxRootRelsXml() {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>
`;
}

function buildDocxDocumentXml(paragraphs) {
  const paragraphXml = paragraphs
    .map((paragraph) => {
      const text = paragraph === '' ? ' ' : paragraph;
      return `<w:p><w:r><w:t xml:space="preserve">${xmlEscape(text)}</w:t></w:r></w:p>`;
    })
    .join('');

  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    ${paragraphXml}
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="708" w:footer="708" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>
`;
}

function buildCorePropsXml(title) {
  const timestamp = new Date().toISOString();
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>${xmlEscape(title)}</dc:title>
  <dc:creator>Codex</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">${xmlEscape(timestamp)}</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">${xmlEscape(timestamp)}</dcterms:modified>
</cp:coreProperties>
`;
}

function buildAppPropsXml(applicationName) {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>${xmlEscape(applicationName)}</Application>
</Properties>
`;
}

function zipDirectory(sourceDir, outputFile) {
  ensureDir(path.dirname(outputFile));
  const command = [
    'Add-Type -AssemblyName System.IO.Compression.FileSystem',
    `$source = ${quotePowerShell(sourceDir)}`,
    `$destination = ${quotePowerShell(outputFile)}`,
    'if (Test-Path $destination) { Remove-Item $destination -Force }',
    '[System.IO.Compression.ZipFile]::CreateFromDirectory($source, $destination)',
  ].join('; ');

  cp.execFileSync('powershell', ['-NoProfile', '-Command', command], {
    stdio: 'inherit',
  });
}

function quotePowerShell(value) {
  return `'${String(value).replace(/'/g, "''")}'`;
}

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function writeText(filePath, contents) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, contents, 'utf8');
}

function xmlEscape(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}
