load("@bazel_skylib//lib:paths.bzl", "paths")

def _impl(rctx):
  absolute_root = str(rctx.path("."))
  execroot = paths.normalize(paths.join(absolute_root, "..", ".."))

  build_content = rctx.read(rctx.attr.build_file)
  rctx.file("BUILD.bazel", content=build_content, executable=False, legacy_utf8=True)

  for label, path in rctx.attr.srcs.items():
    if (label.workspace_root):
        src_path = paths.join(execroot, label.workspace_root)
    else:
        src_path = str(rctx.workspace_root)

    rctx.execute(["mkdir", "-p", path])
    # would need a propeor copy program rather than relying on bash programs
    for f in ["dog.c", "cat.c", "cat.h"]:
        rctx.execute(["cp", "-n", paths.join(src_path, f), path])

merge_repo = repository_rule(
    implementation=_impl,
    local=True,
    attrs={
        "srcs": attr.label_keyed_string_dict(mandatory=True),
        "build_file": attr.label(mandatory=True)
    })
