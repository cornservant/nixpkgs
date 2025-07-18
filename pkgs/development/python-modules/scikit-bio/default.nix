{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  setuptools,
  cython,
  oldest-supported-numpy,

  requests,
  decorator,
  natsort,
  numpy,
  pandas,
  scipy,
  h5py,
  biom-format,
  statsmodels,
  patsy,

  python,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "scikit-bio";
  version = "0.6.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "scikit-bio";
    repo = "scikit-bio";
    tag = version;
    hash = "sha256-yZa9Kl7+Rk4FLQkZIxa9UIsIGAo6YI4UAiJYbhhPIaI=";
  };

  build-system = [
    setuptools
    cython
    oldest-supported-numpy
  ];

  dependencies = [
    requests
    decorator
    natsort
    numpy
    pandas
    scipy
    h5py
    biom-format
    statsmodels
    patsy
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  # only the $out dir contains the built cython extensions, so we run the tests inside there
  enabledTestPaths = [ "${placeholder "out"}/${python.sitePackages}/skbio" ];

  disabledTestPaths = [
    # don't know why, but this segfaults
    "${placeholder "out"}/${python.sitePackages}/skbio/metadata/tests/test_intersection.py"
  ];

  pythonImportsCheck = [ "skbio" ];

  meta = {
    homepage = "http://scikit-bio.org/";
    description = "Data structures, algorithms and educational resources for bioinformatics";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
}
