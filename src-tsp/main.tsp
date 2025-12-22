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
   * The version of cosign that will be included in the image.
   * This will override the default version set by the CLI.
   * Setting to `none` will prevent installing cosign altogether.
   **/
  `cosign-version`?: string;

  /**
   * The version of nushell to include in this image.
   * This will override the default BlueBuild Nushell version.
   * Change only if you need a specific version of Nushell, changing this might break some BlueBuild modules.
   */
  `nushell-version`?: string;

  /**
   * A list of platforms that will be built for the image.
   */
  platforms?: Array<Platform>;

  /**
   * A list of [stages](https://blue-build.org/reference/stages/) that are executed before the build of the final image.
   * This is useful for compiling programs from source without polluting the final bootable image.
   */
  stages?: Array<StageEntry>;

  /**
   * A list of [modules](https://blue-build.org/reference/module/) that is executed in order. Multiple of the same module can be included.
   *
   * Each item in this list should have at least a `type:` or be specified to be included from an external file in the `recipes/` directory with `from-file:`.
   */
  modules: Array<ModuleEntry>;

  /**
   * A collection of custom labels that will be applied to the image.
   *
   * Each item should be a `key: value` pair representing a label name mapping to label value.
   */
  labels?: Record<string>;
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

  /**
   * Determines if a module should execute.
   *
   * There are various methods that a module can be
   * conditionally run. If a string is passed to it,
   * it will be executed by `/bin/sh` at build-time
   * and the exit code will determine if the module executes.
   * A check failing doesn't fail the build, it will just skip the module.
   *
   * The other methods are checking `os-release` at build-time, checking for
   * a host file before build-time, or running a command on the host before build-time.
   *
   * All checks must pass for the module to be executed.
   */
  `if`?: string | ModuleIf;

  /** Secrets to mount for this module call. */
  secrets?: Array<Secret>;
}

alias FlexVal = string | integer | float;

model ModuleIf {
  /**
   * Check if the value in the `/etc/os-release` file
   * matches. This is useful for checking the type/version
   * of the OS before executing the module.
   *
   * A single value or an array of values can be passed in.
   * If an array is passed in, a successful check means at least
   * one value matched.
   */
  `os-release`?: Record<FlexVal | Array<FlexVal>>;

  /**
   * Checks for the existance or non-existance of
   * environment variables at build-time before
   * continuing with the module.
   *
   * You can also check if an environment variable
   * is equal to a value.
   */
  env?: ModuleIfEnv;

  /**
   * Evaluate the string in a shell at build-time,
   * and use the exit-code to determine if the module
   * should run.
   *
   * Equivalent to passing a string to `if:` directly.
   */
  eval?: string;

  /**
   * Checks for the existance or non-existance of a file
   * on the host machine before deciding to template the
   * module call.
   *
   * This can be useful for module calls that use secret files
   * that not every user that clones the repo will have access to.
   */
  `host-file`?: ModuleIfHostFile;

  /**
   * Checks for the existance or non-existance of
   * environment variables on the host machine before
   * deciding to template a module call.
   *
   * You can also check if an environment variable
   * is equal to a value.
   */
  `host-env`?: ModuleIfEnv;

  /**
   * Executes a command on the host machine to determine
   * if the module should be templated.
   *
   * Execution will be performed in the repo directory.
   *
   * CAUTION: This allows arbitrary code execution on the host machine.
   * Be sure to trust the code you are executing by this function. We cannot
   * prevent scripts from operating outside of the repo directory.
   */
  `host-exec`?: ModuleIfHostExec;
}

model ModuleIfHostFile {
  /**
   * A file or list of files that should exist
   * to allow a module to be templated.
   *
   * All paths will be normalized to the root of the
   * the project.
   */
  exists?: string | Array<string>;

  /**
   * A file or list of files that should not exist
   * to allow a module to be templated.
   *
   * All paths will be normalized to the root of the
   * the project.
   */
  `not-exists`?: string | Array<string>;
}

model ModuleIfEnv {
  /**
   * Check if a or all listed environment variables
   * exist and are not empty strings.
   */
  exists?: string | Array<string>;

  /**
   * Check if a or all listed environment variables
   * do not exist, and if they do, that they are empty strings.
   */
  `not-exists`?: string | Array<string>;

  /**
   * Checks if an environment variable equals to
   * one or any listed string.
   */
  equals: Record<string | Array<string>>;
}

model ModuleIfHostExec {
  /**
   * The command to run.
   *
   * It must be a path to an executable file.
   *
   * CAUTION: For safety purposes, setting `sudo`, `run0`, or `pkexec`
   * will error out the program.
   */
  cmd: string;

  /**
   * The arguments to pass into the command.
   */
  args?: Array<string>;
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
