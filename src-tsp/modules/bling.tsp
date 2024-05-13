import "@typespec/json-schema";
using TypeSpec.JsonSchema;

@jsonSchema("/modules/bling.json")
model blingModule {
    install: "ublue-update" | "1password" | "dconf-update-service" | "gnome-vrr" | "laptop" | "flatpaksync"
}