// Configure the Google Cloud provider
provider "google" {
 credentials = file("My-First-Project-168c2e53b1c0.json")
 project     = "singular-tuner-254202"
 region      = "us-central"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "apache-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "us-central1-a"

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

metadata = {
   ssh-keys = "irishman253:${file("~/.ssh/id_rsa.pub")}"
 }
// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get -y install apache2; sudo systemctl start apache2; sudo systemctl enable apache2"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

resource "google_compute_firewall" "default" {
 name = "apache-firewall"
 network = "default"

allow {
 protocol = "tcp"
 ports    = ["80"]
 }
}
