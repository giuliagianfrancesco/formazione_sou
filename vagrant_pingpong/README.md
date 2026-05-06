Vagrant Docker Ping-Pong 
A simple demo where a Docker service swaps between two VMs every 60 seconds using a shared state file.

Quick Start
Bash

vagrant up

Access Points
	•	VM1 Active: http://localhost:3001
	•	VM2 Active: http://localhost:3002
How it works
	1	Infrastructure: Vagrant spins up vm1 and vm2.
	2	Coordination: Both nodes watch /vagrant/turno.txt.
	3	Execution: - The VM matching the name in turno.txt starts the Docker container.
	◦	After 60s, it kills the container and updates turno.txt for the other VM.
	4	Logs: Check progress with tail -f ~/pingpong.log inside the VM.

Essential Commands

Task	        Command

Start		vagrant up
Check Status	vagrant status
Stop		vagrant halt
Reset		vagrant destroy -f && vagrant up

