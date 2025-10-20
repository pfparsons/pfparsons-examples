load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")


cc_library(
    name = "libdnf5",
    srcs = ["/lib64/libdnf5.so"],
    hdrs = ["/include/libdnf5.h"],
)

cc_binary(
    name = "xpm",
    srcs = ["xpm.cc"],
    deps = [":libdnf5"]
)