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

variable "prefix" {
  default = "kubic"
}

variable "network" {
  default = "default"
}

variable "password" {
  default = "linux"
}

variable "devel" {
  default = "true"
}

variable "kubic_init_image_name" {
  default = "localhost/kubic-project/kubic-init:latest"
}

variable "kubic_init_image" {
  default = "kubic-init-latest.tar.gz"
}

variable "seed_memory" {
  default = 2048
}

variable "devel_script" {}

variable "pool" {}

variable "base_volume_name" {}
