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

resource "null_resource" "download_kubic_image" {
  count = "${length(var.img_url_base) == 0 ? 0 : 1}"

  provisioner "local-exec" {
    command = "${path.module}/download-image.sh --sudo-virsh '${var.img_sudo_virsh}' --src-base '${var.img_url_base}' --refresh '${var.img_refresh}' --local '${var.img}' --upload-to-img '${var.prefix}_base_${basename(var.img)}' --upload-to-pool '${var.img_pool}' --src-filename '${var.img_src_filename}' ${var.img_down_extra_args}"
  }
}
