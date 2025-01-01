#!/bin/bash

. ./sh_utils.sh
pfp::log::init
pfp::log_info "it worked"
pfp::log_info "it works - the logging is working"
pfp::log_warn "This is a warning!"
pfp::log_error "Oh no! An Error"
pfp::log_debug "Only when debugging"
pfp::log_fatal "It's all over now"
