provider "google" {
  //credentials = file("terraformpractical-42041d202ffe.json")
  project = "terraformpractical"
  //region      = "us-west1"

}

resource "google_compute_network" "myvpc" {
  name                    = "myvpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.myvpc.name
}

resource "google_compute_firewall" "f1" {
  name    = "firewall"
  network = google_compute_network.myvpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  //source_tags = ["web"]
}

resource "google_compute_instance" "m1" {
  name         = "instance4"
  machine_type = "e2-micro"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1.name
    access_config {
      // for external ip
    }
  }
  /*metadata = {
    ssh-keys = "adam:${file("pubkey.pub")}"
  }*/
  metadata_startup_script = "sudo apt install htop -y"
  /*connection {
    type        = "ssh"
    host        = google_compute_instance.m1.network_interface[0].access_config[0].nat_ip
    user        = "adam"
    private_key = file("prikey.ppk")
  }
  provisioner "remote-exec" {
    inline = [
      "apt install htop -y"
    ]
  }*/
}
output "ip1" {
  value = google_compute_instance.m1.network_interface[0].access_config[0].nat_ip
}
