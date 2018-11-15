#
# Author(s): Alvaro Saurin <alvaro.saurin@suse.com>
#
# Copyright (c) 2017 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.
#

variable "img_pool" {
  default = "default"
}

variable "img_url_base" {
  default = "https://download.opensuse.org/repositories/devel:/kubic:/images:/experimental/images/"
}

variable "img_src_filename" {
  default = ""
}

variable "img" {
  default = "images/kubic.qcow2"
}

variable "img_refresh" {
  default = "true"
}

variable "img_down_extra_args" {
  default = ""
}

variable "img_sudo_virsh" {
  default = "local"
}

variable "prefix" {
  default = "kubic"
}
