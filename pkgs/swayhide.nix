{lib, rustPlatform, fetchFromGitHub}:

rustPlatform.buildRustPackage {
    pname = "swayhide";
    version = "0.2.1";

    src = fetchFromGitHub {
      owner = "rehanzo";
      repo = "swayhide";
      rev = "v0.2.1";
      hash = "sha256-ICDz3oDuXl/DAO4njoLJuv7hRXt76nGPPQlBVcc+hZo=";
    };

    cargoHash =  "sha256-ENuZooDYC2Y19dG5OQYm789fuXjQOkhzFvbCoR8oIO0=";
}
