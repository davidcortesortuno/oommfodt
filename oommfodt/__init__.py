from .oommfodt import OOMMFodt


def test():
    import pytest  # pragma: no cover
    pytest.main(["-v", "--pyargs", "oommfodt"])  # pragma: no cover
