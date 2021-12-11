# Cloud GNS3

Cloud GNS3 is a Ubuntu-based cloud/local VM deployment of GNS3 and all the tools required to run it with access through only a web browser (no need for client-side installs!). It comes in two versions: Vagrant and cloud-init.

## Installation

Clone the Cloud GNS3 GitHub repository to your machine.
```bash
git clone https://github.com/robiworks/cloud-gns3.git
```

### Vagrant

Make sure you are currently in the directory containing the cloned GitHub repository. Move to the `vagrant` directory inside the `cloud-gns3` directory.

```bash
cd vagrant
```

At this point you can change some of the VM settings inside the `Vagrantfile` or stay on the default settings. Some settings you might want to take a look at are listed here.

* Allocate more CPU cores to the VM: modify the line `v.cpus = 2` (default is 2 cores)
* Allocate more RAM to the VM: modify the line `v.memory = 2048` (default is 2048 MB)
* Change the port forwarding settings: modify the line `gns3.vm.network "forwarded_port", guest: 8080, host: 15000` (default is VM 8080 forwards to host 15000)

Now you can start the VM with Vagrant.

```bash
vagrant up
```

Vagrant will download the Ubuntu 20.04 LTS image (if it is not present on your machine yet) and run the provisioning scripts. The provisioning took around 7 minutes on my 2020 laptop on a ~50Mbps connection. The VM reboots automatically after provisioning finishes.

You can now access the Apache Guacamole web interface on [http://localhost:15000/guacamole/](http://localhost:15000/guacamole/). If you changed the port forwarding settings, modify the port accordingly.

Log-in credentials for Apache Guacamole:
* Username: `msi-gns3`
* Password: `msi-gns3`

Log-in credentials for the actual VM:
* Username: `vagrant` (choose on the login screen)
* Password: `vagrant`

### cloud-init

#### Multipass

Make sure you are currently in the directory containing the cloned GitHub repository. Move to the `cloud-init` directory inside the `cloud-gns3` directory.

```bash
cd cloud-init
```

Run the following command to start the VM with the name `mp-gns3`, 2 CPU cores, 2 GB of RAM and a 10 GB disk. You can modify the parameters according to your needs.

```bash
multipass launch --name mp-gns3 --cpus 2 --mem 2G --disk 10G --cloud-init cloud-config.yaml
```

Multipass will download the latest Ubuntu LTS image (if it is not present on your machine yet) and prepare the VM for use. It will probably say this:
```
launch failed: The following errors occurred:                                   
timed out waiting for initialization to complete
```
Don't worry, that's fine. The initialization is taking longer than Multipass expected but the VM is still being prepared. The VM reboots automatically after initialization finishes. The initialization took around 7 minutes on my 2020 laptop on a ~50Mbps connection.

To find your VM's IP address, type `multipass info mp-gns3` (it should look like `10.x.x.x`). You can now access the Apache Guacamole web interface on [http://10.x.x.x:8080/guacamole/](http://10.x.x.x:8080/guacamole/). Make sure to replace `10.x.x.x` in the link with your VM's actual IP address.

Log-in credentials for Apache Guacamole:
* Username: `msi-gns3`
* Password: `msi-gns3`

Log-in credentials for the actual VM:
* Username: `ubuntu` (choose on the login screen)
* Password: `ubuntu`

#### Cloud providers

...

## Usage

After you've logged in to Apache Guacamole and the VM itself, you can start using it like a normal machine with Ubuntu. The VM comes preinstalled with the XFCE4 desktop environment, GNS3, Wireshark and Firefox.

![Find GNS3 in Applications -> Education -> GNS3](https://i.imgur.com/cVhcHjG.png)

You can find **GNS3** in `Applications -> Education -> GNS3`. You can also add it to the desktop for quicker access, just drag it to the desktop. **Wireshark** and **Firefox** are both located in `Applications -> Internet`.

![Create your first GNS3 project](https://i.imgur.com/2pFIHal.png)

GNS3 is **preconfigured** in the VM so you do not have to fiddle with the configuration files. Let's create an example project.

![Basic GNS3 topology](https://i.imgur.com/RMkL7J7.png)

Copy this basic topology using only preinstalled appliances or build your own topology, it's up to you. Click on the green *play* button, the devices will now be simulated. Let's configure the PCs. You can configure them through their terminal or by right-clicking and selecting `Edit config`. For the purposes of this tutorial we will configure them like this:

* PC1: `ip 192.168.0.100/24`
* PC2: `ip 192.168.0.101/24`
* PC3: `ip 192.168.0.102/24`
* PC4: `ip 192.168.0.103/24`

![Wireshark ping capture](https://i.imgur.com/zxzhwii.png)

Right click on the wire going from `Hub1` to `Switch1`, select `Start capture` and Wireshark will start up. Open `PC1`'s terminal and type in `ping 192.168.0.102`. This will send 6 ping packets from `PC1` to `PC3` and you will be able to see them in the Wireshark capture.

![Shut down the VM](https://i.imgur.com/5jreeSm.png)

After you've finished work with your GNS3, you can shut down the VM through the command line (`vagrant halt` or `multipass stop mp-gns3`), you can click on `Ubuntu` in the top right corner and select `Shutdown`, or use your cloud provider's shutdown feature.

![After shutdown](https://i.imgur.com/7ANzt9q.png)

The VM will shut down as expected and Apache Guacamole will notify you that you have been disconnected.
