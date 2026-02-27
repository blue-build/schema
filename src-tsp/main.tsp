import "@typespec/json-schema";
import "./modules/index.tsp";

using TypeSpec.JsonSchema;

@jsonSchema("recipe-v1.json")
@extension("additionalProperties", false)
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
   * Only atomic Fedora images and those based on them are officially supported as of now.
   * [BlueBuild base images](github.com/blue-build/base-images) or [Universal Blue images](https://universal-blue.org/images/) are recommended.
   * Other custom bootc images can be used as well.
   *
   * Example:
   * ```yaml
   * base-image: ghcr.io/blue-build/base-images/fedora-silverblue
   * ```
   */
  `base-image`: string;

  /**
   * The tag of the base image to build on.
   * Used to select a version explicitly (`40`) or to always use the latest stable version (`latest`).
   * A list of all available tags can be viewed by pasting your `base-image` url into your browser.
   */
  `image-version`: string | integer;

  /**
   * The tag to pull for the BlueBuild cli. This is mostly used for
   * trying out specific versions of the cli without compiling it locally.
   * Supply the tag of the cli release container to pull, see [the list of available tags](https://github.com/blue-build/cli/pkgs/container/cli) for reference.
   * Default: `latest-installer`. Set to to `none` to opt out of installing the CLI into your image.
   **/
  `blue-build-tag`?: string;

  /**
   * The version of cosign that will be included in the image.
   * This will override the default version set by the CLI.
   * Setting to `none` will prevent installing cosign altogether.
   **/
  `cosign-version`?: string;

  /**
   * The version of nushell to include at `/usr/libexec/bluebuild/nu/nu` for use by modules in the image.
   * This will override the default BlueBuild Nushell version.
   * Change only if you need a specific version of Nushell, changing this might break some BlueBuild modules.
   * Set to to `none` to opt out of installing Nushell into your image (this will break modules that use Nushell at run time in the final image, like `default-flatpaks`).
   */
  `nushell-version`?: string;

  /**
   * Specify a list of the platforms to build for your image.
   * The resulting images will be added to a manifest list that allows your host’s container runtime to pull the correct image architecture for your hardware. The process of building a multi-architecture image will end up using emulation. Consequently, image builds will take significantly longer and more space will be required on the build host since each platform that is being built is its own image. If `platforms:` is not specified, the build host’s architecture will be used.
   */
  platforms?: Array<Platform>;

  /**
   * A collection of custom labels that will be applied to the image.
   *
   * Each item should be a `key: value` pair representing a label name mapping to label value.
   */
  labels?: Record<string>;

  /**
   * A list of [stages](https://blue-build.org/reference/stages/) that are executed before the build of the final image.
   * This is useful for compiling programs from source without polluting the final bootable image.
   */
  stages?: Array<StageEntry>;

  /**
   * A list of [modules](https://blue-build.org/reference/module/) that is executed in order. Multiple of the same module can be included.
   *
   * Each item in this list needs have at least a `type:` except if the configuration is included from an external file in the `recipes/` directory with [`from-file:`](https://blue-build.org/how-to/multiple-files/).
   *
   * Example:
   *
   * ```yaml
   * modules:
   *  - from-file: common-packages.yml # an external module configuration file for installing commong packages
   *  - type: signing # a module that doesn't require any configuration
   * ```
   */
  modules: Array<ModuleEntry>;

  /**
   * A list of mounts that will be mounted in each RUN stage.
   */
  mounts?: Array<Mount>;
}

enum Platform {
  LinuxAmd64: "linux/amd64",
  LinuxAmd64V2: "linux/amd64/v2",
  LinuxArm64: "linux/arm64",
  LinuxArm: "linux/arm",
  LinuxArmV6: "linux/arm/v6",
  LinuxArmV7: "linux/arm/v7",
  Linux386: "linux/386",
  LinuxLoong64: "linux/loong64",
  LinuxMips: "linux/mips",
  LinuxMipsle: "linux/mipsle",
  LinuxMips64: "linux/mips64",
  LinuxMips64le: "linux/mips64le",
  LinuxPpc64: "linux/ppc64",
  LinuxPpc64le: "linux/ppc64le",
  LinuxRiscv64: "linux/riscv64",
  LinuxS390x: "linux/s390x",
}

@jsonSchema("stage-list-v1.json")
model StageList {
  /**
   * A list of [stages](https://blue-build.org/reference/stages/) that are executed before the build of the final image.
   * This is useful for compiling programs from source without polluting the final bootable image.
   */
  stages: Array<StageEntry>;
}

union StageEntry {
  Stage,
  ImportedModule,
}

@jsonSchema("stage-v1.json")
@extension("additionalProperties", false)
model Stage {
  /**
   * The name of the stage. This is used when referencing
   * the stage when using the from: property in the [`copy` module](https://blue-build.org/reference/modules/copy/).
   */
  name: string;

  /** The full image ref (image name + tag). This will be set in the FROM statement of the stage. */
  from: string;

  /** Defines the platform to run this stage on */
  platform?: Platform;

  /** Allows a user to pass in an array of strings that are passed directly into the [`SHELL` instruction](https://docs.docker.com/reference/dockerfile/#shell). */
  shell?: string;

  /**
   * The list of modules to execute. The exact same syntax used by the main recipe `modules:` property.
   */
  modules: Array<ModuleEntry>;
}

@jsonSchema("module-list-v1.json")
model ModuleList {
  /**
   * A list of [modules](https://blue-build.org/reference/module/) that is executed in order. Multiple of the same module can be included.
   *
   * Each item in this list should have at least a `type:` or be specified to be included from an external file in the `recipes/` directory with `from-file:`.
   */
  modules: Array<ModuleEntry>;
}

union ModuleEntry {
  Module,
  ImportedModule,
}

@jsonSchema("module-v1.json")
union Module {
  RepoModule,
  CustomModule,
}

model ModuleDefaults {
  /** Whether to disabling caching for this layer.
   * https://blue-build.org/reference/module/#no-cache-optional
   */
  `no-cache`?: boolean = false;

  /** Environment variables to add for the module call.
   */
  env?: Record<string>;

  /** Secrets to mount for this module call. */
  secrets?: Array<Secret>;
}

@oneOf
union Secret {
  SecretEnv,
  SecretFile,
  SecretExec,
  SecretSsh,
}

model SecretEnv {
  /** A secret pulled from an environment variable. */
  type: "env";

  /** The name of the environment variable */
  name: string;

  /** Defines the mount type for the result of the command into the build. */
  mount: SecretMount;
}

model SecretFile {
  /** A secret pulled from a file. */
  type: "file";

  /** The source file containing the secret.
   *
   * NOTE: Relative paths are relative to the root of the repository.
   */
  source: string;

  /** Defines the mount type for the result of the command into the build. */
  mount: SecretMount;
}

model SecretExec {
  /** A secret pulled from the stdout of a command. */
  type: "exec";

  /** The command that will be executed. */
  command: string;

  /** Arguments for the command being executed. */
  args?: Array<string>;

  /** Defines the mount type for the result of the command into the build. */
  mount: SecretMount;
}

model SecretSsh {
  /** Mount the SSH socket to use the hosts SSH socket. */
  type: "ssh";
}

union SecretMount {
  SecretMountEnv,
  SecretMountFile,
}

model SecretMountEnv {
  /** A secret pulled from a file on the host system. */
  type: "env";

  /** The environment variable where the secret will be set. */
  name: string;
}

model SecretMountFile {
  /** A secret pulled from a file on the host system. */
  type: "file";

  /** The destination path in the build to mount the secret. */
  destination: string;
}

@jsonSchema("module-custom-v1.json")
model CustomModule {
  /** This is not a built-in module. */
  type: string;

  /** The image ref of the module repository (an OCI image) to pull the module from.
   * If this is a local module, set the value to 'local'.
   * https://blue-build.org/reference/module/#source-optional
   */
  source: string;

  ...ModuleDefaults;
  ...Record<unknown>;
}

@extension("additionalProperties", false)
@jsonSchema("import-v1.json")
model ImportedModule {
  /** The path to another file containing module configuration to import here.
   * https://blue-build.org/how-to/multiple-files/
   */
  `from-file`: string;
}

@jsonSchema("module-stage-list-v1.json")
@extension("additionalProperties", false)
model ModuleStageList {
  /**
   * A list of [modules](https://blue-build.org/reference/module/) that is executed in order. Multiple of the same module can be included.
   *
   * Each item in this list should have at least a `type:` or be specified to be included from an external file in the `recipes/` directory with `from-file:`.
   */
  modules?: Array<ModuleEntry>;

  /**
   * A list of [stages](https://blue-build.org/reference/stages/) that are executed before the build of the final image.
   * This is useful for compiling programs from source without polluting the final bootable image.
   */
  stages?: Array<StageEntry>;
}

@oneOf
union Mount {
  MountBind,
  MountTmpFs,
  MountCache,
}

model MountBind {
  /** A bind mount from the host system. */
  type: "bind";

  /** The source path on the host system to mount. */
  source: string;

  /** The destination path to mount to. */
  destination: string;

  /** Whether the mount should be read-only. */
  readOnly?: boolean;
}

model MountTmpFs {
  /** A temporary file system mount. */
  type: "tmpfs";

  /** The destination path to mount to. */
  destination: string;

  /** The size of the tmpfs mount. */
  size?: string;
}

enum MountCacheSharing {
  Shared = "shared",
  Private = "private",
  Locked = "locked",
}

model MountCache {
  /** A cache mount. */
  type: "cache";

  /** The destination path to mount to. */
  destination: string;

  /** An identifier for the cache. */
  id?: string;

  /** The sharing mode of the cache. */
  sharing?: MountCacheSharing;
}