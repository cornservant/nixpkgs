{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  h5py,
  pytestCheckHook,
  netcdf4,
  pythonOlder,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "h5netcdf";
  version = "1.6.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "h5netcdf";
    repo = "h5netcdf";
    tag = "v${version}";
    hash = "sha256-frKnnUh5OFeQGAhf/y5idMWGb0ufHznz4u5A8FRJSuA=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ h5py ];

  nativeCheckInputs = [
    pytestCheckHook
    netcdf4
  ];

  pythonImportsCheck = [ "h5netcdf" ];

  meta = with lib; {
    description = "Pythonic interface to netCDF4 via h5py";
    homepage = "https://github.com/shoyer/h5netcdf";
    changelog = "https://github.com/h5netcdf/h5netcdf/releases/tag/${src.tag}";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
