import "@typespec/json-schema";
import "./modules/index.tsp";

using TypeSpec.JsonSchema;

@jsonSchema("recipe-v1.json")
model Recipe {
    /**
     * The image name. Used when publishing to GHCR as `ghcr.io/user/name`.
     */
    name: string,

    /**
     * The image description. Published to GHCR in the image metadata.
     */
    description: string,

    /**
     * The [OCI](https://opencontainers.org/) image to base your custom image on.
     * Only atomic Fedora images and those based on them are officially supported.
     * Universal Blue is recommended. [A list of Universal Blue's images](https://universal-blue.org/images/) can be found on their website
     * BlueBuild-built images can be used as well. */
    "base-image": string,
    
    /**
     * The tag of the base image to build on.
     * Used to select a version explicitly (`40`) or to always use the latest stable version (`latest`).
     * A list of all available tags can be viewed by pasting your `base-image` url into your browser.
     */
    "image-version": string,

    /**
     * A list of [modules](https://blue-build.org/reference/module/) that is executed in order. Multiple of the same module can be included.
     * 
     * Each item in this list should have at least a `type:` or be specified to be included from an external file in the `recipes/` directory with `from-file:`.
     */
    modules: Array<Module>
}