const path = require('node:path');
const fs = require('node:fs');
const _ = require("lodash");

const LINKED_PLUGINS_MODULE_TEMPLATE = (plugins) => {
  const importableName = (name) => _.upperFirst(_.camelCase(name));
  const frontendPlugins = plugins.map(([name, _]) => [name, importableName(name)]);

  return `
import {NgModule} from "@angular/core";
${
  frontendPlugins
    .map(([actualName, moduleName]) => 
      `import {PluginModule as ${moduleName}} from './linked/${actualName}/main';`
    )
    .join("\n")
}

@NgModule({
    imports: [
        ${
          frontendPlugins
            .map(([_, moduleName]) => moduleName)
            .join(`,\n${" ".repeat(8)}`)
        }
    ],
})
export class LinkedPluginsModule { }
  `;
};

const railsRout = path.join(__dirname, "..");
const pluginDir = path.join(railsRout, 'modules');
const targetDir = path.join(railsRout, 'frontend/src/app/features/plugins/linked');

const plugins = new Map([
  ["budgets", path.join(pluginDir, "budgets")],
  ["costs", path.join(pluginDir, "costs")],
  ["openproject-avatars", path.join(pluginDir, "avatars")],
  ["openproject-documents", path.join(pluginDir, "documents")],
  ["openproject-github_integration", path.join(pluginDir, "github_integration")],
  ["openproject-gitlab_integration", path.join(pluginDir, "gitlab_integration")],
  ["openproject-meeting", path.join(pluginDir, "meeting")]
]);

console.log(`Cleaning linked target directory ${targetDir}`);
fs.rmSync(targetDir, { recursive: true, force: true });
fs.mkdirSync(targetDir);

plugins.forEach((pluginPath, name) => {
  const linkTarget = path.join(pluginPath, "frontend", "module");
  const linkPath = path.join(targetDir, name);

  console.log(`Linking frontend of OpenProject plugin ${name} to ${linkPath}.`)
  fs.symlinkSync(linkTarget, linkPath);
});

const allFrontendPlugins = Array.from(plugins).filter(([_, pluginPath]) => {
  const frontendEntry = path.join(pluginPath, "frontend", "module", "main.ts");
  return fs.existsSync(frontendEntry);
});

function generatePluginModule(plugins) {
  const fileRegister = path.join(railsRout, "frontend/src/app/features/plugins/linked-plugins.module.ts");
  console.log(`Regenerating frontend plugin registry ${fileRegister}.`);

  const result = LINKED_PLUGINS_MODULE_TEMPLATE(plugins);
  fs.writeFileSync(fileRegister, result);
};

generatePluginModule(allFrontendPlugins);
