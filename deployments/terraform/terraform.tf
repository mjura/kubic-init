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

#######################
# Externals           #
#######################

# provisioning script to use in development environments
data "template_file" "init_script" {
  template = "${file("provision/devel.sh.tpl")}"

  vars {
    kubic_init_image = "${var.kubic_init_image}"
  }
}

#######################
# Cluster declaration #
#######################

provider "libvirt" {
  uri = "${var.libvirt_uri}"
}

###########################
# Common                  #
###########################

module "base" {
  source = "./modules/base"

  img                 = "${var.img}"
  img_down_extra_args = "${var.img_down_extra_args}"
  img_pool            = "${var.img_pool}"
  img_refresh         = "${var.img_refresh}"
  img_src_filename    = "${var.img_src_filename}"
  img_sudo_virsh      = "${var.img_sudo_virsh}"
  img_url_base        = "${var.img_url_base}"
  prefix              = "${var.prefix}"
}

module "seeder" {
  source = "./modules/seeder"

  devel                 = "${var.devel}"
  devel_script          = "${data.template_file.init_script.rendered}"
  pool                  = "${module.base.pool}"
  base_volume_name      = "${module.base.base_volume_name}"
  kubic_init_image      = "${var.kubic_init_image}"
  kubic_init_image_name = "${var.kubic_init_image_name}"
  network               = "${var.network}"
  password              = "${var.password}"
  prefix                = "${var.prefix}"
}

module "nodes" {
  source = "./modules/nodes"

  default_node_memory   = "${var.default_node_memory}"
  devel                 = "${var.devel}"
  devel_script          = "${data.template_file.init_script.rendered}"
  pool                  = "${module.base.pool}"
  base_volume_name      = "${module.base.base_volume_name}"
  kubic_init_image      = "${var.kubic_init_image}"
  kubic_init_image_name = "${var.kubic_init_image_name}"
  network               = "${var.network}"
  nodes_count           = "${var.nodes_count}"
  nodes_memory          = "${var.nodes_memory}"
  password              = "${var.password}"
  prefix                = "${var.prefix}"
  seeder                = "${module.seeder.address}"
  token                 = "${module.seeder.token}"
}

###########################
# Output                  #
###########################

output "seeder" {
  value = "${module.seeder.address}"
}

output "token" {
  value = "${module.seeder.token}"
}
