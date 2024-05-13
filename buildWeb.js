import fs from "node:fs";
import path from "node:path";

const sourceDir = './tsp-output/@typespec/json-schema';
const buildDir = './dist';

console.log("Building final web output into " + buildDir);

fs.existsSync(buildDir) && fs.rmSync(buildDir, { recursive: true });
fs.mkdirSync(buildDir)
fs.mkdirSync(`${buildDir}/modules`);

fs.copyFileSync('./src-web/_headers', `${buildDir}/_headers`);

const ids = []

fs.readdirSync(sourceDir).forEach((file) => {
    if (file.endsWith('.json')) {
        const filePath = path.join(sourceDir, file);
        const { $id } = JSON.parse(fs.readFileSync(filePath));
        fs.copyFileSync(filePath, `${buildDir}/${$id}`);
        ids.push($id)
    }
});

console.log("Files built: " + ids.join(', '))
console.log("Generating index.html...")

const template = fs.readFileSync('./src-web/template-index.html').toString()
const indexHtml = template.replace(
    '%DYNAMIC_SCHEMA_LIST%',
    ids.map(
        id => `<li><a href="${id}">${id}</a></li>`
    ).join('')
)

fs.writeFileSync(`${buildDir}/index.html`, indexHtml)