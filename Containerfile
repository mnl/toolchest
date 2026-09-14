FROM docker.io/alpine:3.23

RUN : Add tools from Alpine \
		&& \
	apk --no-cache add \
	age=~1.2 \
	bash-completion=~2 \
	bash=~5.3 \
	bat=~0.26 \
	btop=~1.4 \
	choose=~1.3 \
	coreutils=~9.8 \
	cosign=~2 \
	crane=~0.20 \
	curl=~8 \
	delta=~0.18 \
	doggo=~1.1 \
	dust=~1.2 \
	eza=~0.23 \
	fd=~10 \
	fx=~39 \
	fzf=~0.67 \
	gawk=~5.3 \
	gping=~1.20 \
	grype=~0.104 \
	helm=~3.19 \
	hyperfine=~1.20 \
	jq=~1.8 \
	just=~1.43 \
	k9s=~0.50 \
	kubectl=~1.34 \
	kubectx=~0.9 \
	kustomize=~5.7 \
	moreutils=~0.70 \
	procs=~0.14 \
	pv=~1.10 \
	rclone=~1.72 \
	ripgrep=~15 \
	sd=~1 \
	sed=~4 \
	shellcheck=~0.11 \
	shfmt=~3.11 \
	sops=~3.11 \
	syft=~1.38 \
	uv=~0.10 \
	xh=~0.24 \
	xsv=~0.13 \
	yq=~4.49 \
	;

# Add dive
ADD --checksum=sha256:0970549eb4a306f8825a84145a2534153badb4d7dcf3febd1967c706367c3d0e \
	https://github.com/wagoodman/dive/releases/download/v0.13.1/dive_0.13.1_linux_amd64.tar.gz \
	/tmp/dive.tar.gz
RUN : Install Dive binary \
		&& \
	mkdir -p /tmp/dive \
	&& tar -xzf /tmp/dive.tar.gz -C /tmp/dive \
	&& install -Dm755 /tmp/dive/dive /usr/local/bin/dive \
	&& install -Dm644 /tmp/dive/LICENSE /usr/share/licenses/dive/LICENSE \
	&& rm -rf /tmp/dive /tmp/dive.tar.gz \
	dive completion bash > /usr/share/bash-completion/completions/dive

# Add grex
ADD --checksum=sha256:8f02f4ebe72d9e3098c646b77f7bc53ec8a8c1fb51ed042db06b739d08e56af8 \
	https://github.com/pemistahl/grex/releases/download/v1.4.6/grex-v1.4.6-x86_64-unknown-linux-musl.tar.gz \
	/tmp/grex.tar.gz
RUN : Install Grex binary \
		&& \
	tar -xzf /tmp/grex.tar.gz -C /usr/local/bin/ grex \
	&& rm -rf /tmp/grex.tar.gz

# Add stern
ADD --checksum=sha256:7754adfa653939240f7d20fff4ada9b69cda40c9e70732301f67bb8045f1ef3e \
	https://github.com/stern/stern/releases/download/v1.34.0/stern_1.34.0_linux_amd64.tar.gz \
	/tmp/stern.tar.gz
RUN : Install Stern binary \
		&& \
	mkdir -p /tmp/stern \
	&& tar -xzf /tmp/stern.tar.gz -C /tmp/stern \
	&& install -Dm755 /tmp/stern/stern /usr/local/bin/stern \
	&& install -Dm644 /tmp/stern/LICENSE /usr/share/licenses/stern/LICENSE \
	&& rm -rf /tmp/stern /tmp/stern.tar.gz \
	stern completion bash > /usr/share/bash-completion/completions/stern

# Add oras
ADD --checksum=sha256:9ce999f8d2de03fc03968b29d743077a58783e545e5eaa53917ca177352d0e59 \
	https://github.com/oras-project/oras/releases/download/v1.3.3/oras_1.3.3_linux_amd64.tar.gz \
	/tmp/oras.tar.gz
RUN : Install Oras binary \
		&& \
	mkdir -p /tmp/oras \
	&& tar -xzf /tmp/oras.tar.gz -C /tmp/oras \
	&& install -Dm755 /tmp/oras/oras /usr/local/bin/oras \
	&& install -Dm644 /tmp/oras/LICENSE /usr/share/licenses/oras/LICENSE \
	&& rm -rf /tmp/oras /tmp/oras.tar.gz \
	oras completion bash > /usr/share/bash-completion/completions/oras

# Add grpcurl
ADD --checksum=sha256:a926b62a85787ccf73ef8736b3ae554f1242e39d92bb8767a79d6dd23b11d1d5 \
	https://github.com/fullstorydev/grpcurl/releases/download/v1.9.3/grpcurl_1.9.3_linux_x86_64.tar.gz \
	/tmp/grpcurl.tar.gz
RUN : Install Grpcurl binary \
		&& \
	mkdir -p /tmp/grpcurl \
	&& tar -xzf /tmp/grpcurl.tar.gz -C /tmp/grpcurl \
	&& install -Dm755 /tmp/grpcurl/grpcurl /usr/local/bin/grpcurl \
	&& install -Dm644 /tmp/grpcurl/LICENSE /usr/share/licenses/grpcurl/LICENSE \
	&& rm -rf /tmp/grpcurl /tmp/grpcurl.tar.gz

COPY rootfs/bashrc /root/.bashrc
COPY rootfs/inputrc /root/.inputrc

RUN : Toolbx required packages \
		&& \
	 apk add --no-cache \
	findutils \
	libc-utils \
	libcap-utils \
	ncurses-terminfo-base \
	shadow \
	sudo \
	util-linux \
	&& addgroup -S wheel 2>/dev/null || true

RUN : Toolbx file and directories \
		&& \
	printf '%%wheel ALL=(ALL:ALL) NOPASSWD: ALL\n' \
		>/etc/sudoers.d/toolbox \
	&& chmod 0440 /etc/sudoers.d/toolbox \
	&& mkdir -p \
		/etc/krb5.conf.d \
		/etc/ld.so.conf.d \
		/etc/pkcs11/modules \
		/usr/share/empty \
	&& echo 'VARIANT="Toolbx image"' >> /etc/os-release \
	&& echo IMAGE_ID="toolchest" >> /etc/os-release \
	&& ln -s /etc/terminfo /usr/share/terminfo \
	&& find /home /media -mindepth 1 -delete

LABEL com.github.containers.toolbox="true" \
	org.opencontainers.image.description="A toolchest of useful programs" \
	org.opencontainers.image.authors=mnl \
	org.opencontainers.image.title=toolchest

USER 0

ENTRYPOINT []
CMD ["/bin/bash"]
