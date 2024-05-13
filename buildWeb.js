import fs from "node:fs";
import path from "node:path";

const sourceDir = './tsp-output/@typespec/json-schema';
const buildDir = './dist';

console.log("Building final web output into " + buildDir);

fs.existsSync(buildDir) && fs.rmSync(buildDir, { recursive: true });
fs.mkdirSync(buildDir)
fs.mkdirSync(`${buildDir}/modules`);

fs.copyFileSync('./_headers', `${buildDir}/_headers`);

fs.readdirSync(sourceDir).forEach((file) => {
    if (file.endsWith('.json')) {
        const filePath = path.join(sourceDir, file);
        const { $id } = JSON.parse(fs.readFileSync(filePath));
        fs.copyFileSync(filePath, `${buildDir}/${$id}`);
    }
});

