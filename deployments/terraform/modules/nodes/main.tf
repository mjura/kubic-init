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

resource "libvirt_volume" "node" {
  count            = "${var.nodes_count}"
  name             = "${var.prefix}_node_${count.index}.qcow2"
  pool             = "${var.pool}"
  base_volume_name = "${var.base_volume_name}"
}

data "template_file" "node_cloud_init_user_data" {
  count    = "${var.nodes_count}"
  template = "${file("${path.module}/cloud-init.cfg.tpl")}"

  vars {
    seeder   = "${var.seeder}"
    token    = "${var.token}"
    password = "${var.password}"
    hostname = "${var.prefix}-node-${count.index}"
  }
}

resource "libvirt_cloudinit_disk" "node" {
  count     = "${var.nodes_count}"
  name      = "${var.prefix}_node_cloud_init_${count.index}.iso"
  pool      = "${var.pool}"
  user_data = "${element(data.template_file.node_cloud_init_user_data.*.rendered, count.index)}"
}

resource "libvirt_domain" "node" {
  count     = "${var.nodes_count}"
  name      = "${var.prefix}-node-${count.index}"
  memory    = "${lookup(var.nodes_memory, count.index, var.default_node_memory)}"
  cloudinit = "${element(libvirt_cloudinit_disk.node.*.id, count.index)}"

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = "${element(libvirt_volume.node.*.id, count.index)}"
  }

  network_interface {
    network_name   = "${var.network}"
    wait_for_lease = 1
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}

resource "null_resource" "upload_config_nodes" {
  count = "${var.devel == "true" ? var.nodes_count : 0}"

  connection {
    host     = "${element(libvirt_domain.node.*.network_interface.0.addresses.0, count.index)}"
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
