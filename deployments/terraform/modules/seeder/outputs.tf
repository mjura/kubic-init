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

locals {
  "external_addr"  = "${data.external.seeder.result.address}"
  "libvirt_addr"   = "${element(concat(libvirt_domain.seed.*.network_interface.0.addresses, list("")), 0)}"
  "seeder_address" = "${length(local.external_addr) > 0 ? local.external_addr : local.libvirt_addr }"
}

output "address" {
  depends_on = [
    "libvirt_domain.seed",
    "null_resource.upload_config_seeder",
  ]

  # libvirt_domain.seed.network_interface.0.addresses.0
  value = "${local.seeder_address}"
}

output "token" {
  depends_on = [
    "libvirt_domain.seed",
    "null_resource.upload_config_seeder",
  ]

  value = "${data.external.token_get.result.token}"
}
