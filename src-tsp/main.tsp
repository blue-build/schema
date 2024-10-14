import "@typespec/json-schema";
import "./modules/index.tsp";

using TypeSpec.JsonSchema;

@jsonSchema("recipe-v1.json")
model Recipe {
  /**
   * The image name. Used when publishing to GHCR as `ghcr.io/user/name`.
   */
  name: string;

  /**
   * The image description. Published to GHCR in the image metadata.
   */
  description: string;

  /**
   * Allows setting custom tags on the recipe’s final image.
   * Adding tags to this property will override the `latest` and timestamp tags.
   */
  `alt-tags`?: Array<string>;

  /**
   * The [OCI](https://opencontainers.org/) image to base your custom image on.
   * Only atomic Fedora images and those based on them are officially supported.
   * Universal Blue is recommended. [A list of Universal Blue's images](https://universal-blue.org/images/) can be found on their website
   * BlueBuild-built images can be used as well.
   */
  `base-image`: string;

  /**
   * The tag of the base image to build on.
   * Used to select a version explicitly (`40`) or to always use the latest stable version (`latest`).
   * A list of all available tags can be viewed by pasting your `base-image` url into your browser.
   */
  `image-version`: string | integer;

  /**
   * The tag to pull for the bluebuild cli. This is mostly used for
   * trying out specific versions of the cli without compiling it locally.
   **/
  `blue-build-tag`?: string;

  /**
   * A list of [stages](https://blue-build.org/reference/stages/) that are executed before the build of the final image.
   * This is useful for compiling programs from source without polluting the final bootable image.
   */
  stages?: Array<Stage | ImportedModule>;

  /**
   * A list of [modules](https://blue-build.org/reference/module/) that is executed in order. Multiple of the same module can be included.
   *
   * Each item in this list should have at least a `type:` or be specified to be included from an external file in the `recipes/` directory with `from-file:`.
   */
  modules: Array<ModuleType | ImportedModule>;
}

@jsonSchema("stage-list-v1.json")
model StageList {
  stages: Array<Stage | ImportedModule>;
}

@jsonSchema("stage-v1.json")
model Stage {
  /**
   * The name of the stage. This is used when referencing
   * the stage when using the from: property in the [`copy` module](https://blue-build.org/reference/modules/copy/).
   */
  name: string;

  /** The full image ref (image name + tag). This will be set in the FROM statement of the stage. */
  from: string;

  /** Allows a user to pass in an array of strings that are passed directly into the [`SHELL` instruction](https://docs.docker.com/reference/dockerfile/#shell). */
  shell?: string;

  /**
   * The list of modules to execute. The exact same syntax used by the main recipe `modules:` property.
   */
  modules: Array<ModuleType | ImportedModule>;
}

@jsonSchema("module-list-v1.json")
model ModuleList {
  modules: Array<ModuleType | ImportedModule>;
}

@jsonSchema("module-v1.json")
union ModuleType {
  normal: NormalModules,
  custom: CustomModule,
}

@discriminator("type")
union NormalModules {
  akmods: AkmodsModule,
  bling: BlingModule,
  brew: BrewModule,
  chezmoi: ChezmoiModule,
  containerfile: ContainerfileModule,
  copy: CopyModule,
  default_flatpaks: DefaultFlatpaksModule,
  files: FilesModule,
  fonts: FontsModule,
  gnome_extentions: GnomeExtensionsModule,
  gschema_overrides: GschemaOverridesModule,
  justfiles: JustfilesModule,
  rpm_ostree: RpmOstreeModule,
  script: ScriptModule,
  signing: SigningModule,
  systemd: SystemdModule,
  yafti: YaftiModule,
}

@discriminator("type")
model Module {
  /** This is not a built-in module. */
  type: string;

  /** Whether to disabling caching for this layer.
   * https://blue-build.org/reference/module/#no-cache-optional
   */
  `no-cache`?: boolean = false;
}

model CustomModule {
  /** This is not a built-in module. */
  type: string;

  /** Whether to disabling caching for this layer.
   * https://blue-build.org/reference/module/#no-cache-optional
   */
  `no-cache`?: boolean = false;

  /** The URL of the module repository (an OCI image) to pull the module from.
   * https://blue-build.org/reference/module/#source-optional
   */
  source?: string;

  ...Record<unknown>;
}

model ImportedModule {
  /** The path to another file containing module configuration to import here.
   * https://blue-build.org/how-to/multiple-files/
   */
  `from-file`: string;
}
