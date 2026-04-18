# Sphinx configuration for mcDETECT tutorial (MyST Markdown).
# https://www.sphinx-doc.org/en/master/usage/configuration.html

project = "mcDETECT tutorial"
copyright = "mcDETECT contributors"
author = "mcDETECT contributors"

extensions = [
    "myst_parser",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]

# MyST (https://myst-parser.readthedocs.io/)
myst_enable_extensions = ["colon_fence", "deflist"]

# Tutorial pages use H1 then ### subsections; allow non-consecutive levels.
suppress_warnings = ["myst.header"]
