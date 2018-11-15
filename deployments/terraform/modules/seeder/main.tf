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

data "external" "seeder" {
  program = [
    "python",
    "${path.module}/get-seeder.py",
  ]
}

data "external" "token_get" {
  program = [
    "python",
    "${path.module}/get-token.py",
  ]
}

##############
# Seed node #
##############

resource "libvirt_volume" "seed" {
  count = "${data.external.seeder.result.computed == "true" ? 1 : 0}"
  name  = "${var.prefix}_seed.qcow2"

  pool             = "${var.pool}"
  base_volume_name = "${var.base_volume_name}"
}

data "template_file" "seed_cloud_init_user_data" {
  count = "${data.external.seeder.result.computed == "true" ? 1 : 0}"

  template = "${file("${path.module}/cloud-init.cfg.tpl")}"

  vars {
    password              = "${var.password}"
    hostname              = "${var.prefix}-seed"
    token                 = "${data.external.token_get.result.token}"
    kubic_init_image_name = "${var.kubic_init_image_name}"
  }
}

resource "libvirt_cloudinit_disk" "seed" {
  count = "${data.external.seeder.result.computed == "true" ? 1 : 0}"

  name      = "${var.prefix}_seed_cloud_init.iso"
  pool      = "${var.pool}"
  user_data = "${data.template_file.seed_cloud_init_user_data.rendered}"
}

resource "libvirt_domain" "seed" {
  count = "${data.external.seeder.result.computed == "true" ? 1 : 0}"

  name      = "${var.prefix}-seed"
  memory    = "${var.seed_memory}"
  cloudinit = "${libvirt_cloudinit_disk.seed.id}"

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = "${libvirt_volume.seed.id}"
  }

  network_interface {
    network_name   = "${var.network}"
    wait_for_lease = 1
  }

  # we should use something like this:
  #
  # network_interface = ["${slice(
  #   list(
  #     map("wait_for_lease", true,
  #         "network_name", var.base_configuration["network_name"],
  #         "bridge", var.base_configuration["bridge"],
  #         "mac", var.mac
  #        ),
  #     map("wait_for_lease", false,
  #         "network_id", var.base_configuration["additional_network_id"]
  #        )
  #   ),
  #   var.connect_to_base_network ? 0 : 1,
  #   (var.base_configuration["additional_network"] && var.connect_to_additional_network) ? 2 : 1
  # )}"]

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}

resource "null_resource" "upload_config_seeder" {
  count = "${var.devel == "true" && data.external.seeder.result.computed == "true" ? 1 : 0}"

  connection {
    host     = "${libvirt_domain.seed.network_interface.0.addresses.0}"
    password = "${var.password}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/systemd/system/kubelet.service.d",
    ]
  }

  provisioner "file" {
    source      = "${path.root}/../../init/kubelet.drop-in.conf"
    destination = "/etc/systemd/system/kubelet.service.d/kubelet.conf"
  }

  provisioner "file" {
    source      = "${path.root}/../../init/kubic-init.systemd.conf"
    destination = "/etc/systemd/system/kubic-init.service"
  }

  provisioner "file" {
    source      = "${path.root}/../../init/kubic-init.sysconfig"
    destination = "/etc/sysconfig/kubic-init"
  }

  provisioner "file" {
    source      = "${path.root}/../../init/kubelet-sysctl.conf"
    destination = "/etc/sysctl.d/99-kubernetes-cri.conf"
  }

  provisioner "file" {
    source      = "${path.root}/../../${var.kubic_init_image}"
    destination = "/tmp/${var.kubic_init_image}"
  }

  # TODO: this is only for development
  provisioner "remote-exec" {
    inline = "${var.devel_script}"
  }
}
