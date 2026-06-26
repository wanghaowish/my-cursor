#!/usr/bin/env node
/**
 * 5× 超清全页截图（1400px viewport → 7000px 宽 PNG）
 *
 * Usage:
 *   node screenshot-uhd.js [htmlPath] [outPath]
 *
 * Defaults:
 *   htmlPath = ./industry-map.html (cwd)
 *   outPath  = ./industry-map-uhd.png (cwd)
 *
 * Env:
 *   CHROME_PATH — Chrome/Chromium executable (default: /usr/local/bin/google-chrome)
 */
const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

const htmlPath = path.resolve(process.argv[2] || 'industry-map.html');
const outPath = path.resolve(process.argv[3] || 'industry-map-uhd.png');
const chromePath = process.env.CHROME_PATH || '/usr/local/bin/google-chrome';
const baseWidth = 1400;
const scale = 5;

(async () => {
  if (!fs.existsSync(htmlPath)) {
    console.error('HTML not found:', htmlPath);
    process.exit(1);
  }
  fs.mkdirSync(path.dirname(outPath), { recursive: true });

  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: baseWidth, height: 800, deviceScaleFactor: scale });
  await page.goto('file://' + htmlPath, { waitUntil: 'networkidle0' });
  await page.evaluate(() => document.fonts.ready);
  const height = await page.evaluate(() => document.body.scrollHeight);
  await page.setViewport({ width: baseWidth, height, deviceScaleFactor: scale });
  await page.screenshot({
    path: outPath,
    fullPage: true,
    type: 'png',
    captureBeyondViewport: true,
  });
  await browser.close();

  const stat = fs.statSync(outPath);
  const dim = require('child_process').execSync(`file "${outPath}"`).toString().trim();
  console.log('Saved:', outPath);
  console.log(dim);
  console.log('bytes:', stat.size);
})();
