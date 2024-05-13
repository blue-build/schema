import "@typespec/json-schema";
import "./modules.tsp";

using TypeSpec.JsonSchema;

@jsonSchema("recipe.json")
model recipe {
    name: string,
    description: string,
    "base-image": string,
    "image-version": string,
    modules: Array<Module>
}