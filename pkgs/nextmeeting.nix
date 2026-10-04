{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "nextmeeting";
  version = "main";

  src = fetchFromGitHub {
    owner = "chmouel";
    repo = "nextmeeting";
    rev = "main";
    hash = "sha256-3o1mFUYtAt27Dp5jX8oNmudy3smtnl/gGeetJS+HXEU=";
  };

  format = "pyproject";

  nativeBuildInputs = [
    python3Packages.hatchling
  ];

  propagatedBuildInputs = with python3Packages; [
    python-dateutil
    caldav
  ];
}
