const fs = require("fs");

const BASE_URL = process.env.SITE_URL;

const PAGES = [
  "/",
  "/corpora.html"
];

const TODAY = new Date().toISOString().split("T")[0];

let xml = `<?xml version="1.0" encoding="UTF-8"?>\n`;
xml += `<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n`;

PAGES.forEach(path => {
  xml += `  <url>\n`;
  xml += `    <loc>${BASE_URL}${path}</loc>\n`;
  xml += `    <lastmod>${TODAY}</lastmod>\n`;
  xml += `    <changefreq>weekly</changefreq>\n`;
  xml += `    <priority>0.80</priority>\n`;
  xml += `  </url>\n`;
});

xml += `</urlset>\n`;

fs.writeFileSync("sitemap.xml", xml);
console.log("Generated sitemap.xml for " + BASE_URL);
