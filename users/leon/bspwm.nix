self: super: {
  bspwm-rounded = super.bspwm.overrideAttrs (old: {
    pname = "bspwm-rounded";
    version = "0.9.10";

    src = super.fetchFromGitHub {
      owner = "phuhl";
      repo = "bspwm-rounded";
      rev = "a510c368595cd530713cc9d850842ba096051d12";
      sha256 = "sha256-rNvnG2xR3vrY0Dw6alx5HkfUQ2gABF9Mc7JWwcg6m2I=";
    };
  });
}
