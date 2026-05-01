#!/usr/bin/env rake
# Cross-compile a Spinel program to common targets.
#
# Usage:
#   rake xc SRC=examples/nats_info.rb              # all targets
#   rake xc:linux-x86_64 SRC=examples/foo.rb       # one target
#   rake xc:targets                                # list targets
#
# Environment overrides:
#   SRC=...     Required. Path to the .rb source.
#   DIST=...    Output directory (default: ./dist)
#   CC="..."    C compiler command (default: "zig cc")
#
# Defaults to `zig cc` since it ships libc + headers for many targets in
# a single binary. Replace with any cross-toolchain that accepts the
# same flags, e.g. CC="aarch64-linux-gnu-gcc" rake xc:linux-arm64.

require 'rake/clean'

SPINEL_DIR = __dir__
DIST       = ENV['DIST'] || File.join(SPINEL_DIR, 'dist')
BUILD_XC   = File.join(SPINEL_DIR, 'build', 'xc')
CC         = (ENV['CC'] || 'zig cc').split

TARGETS = {
  'linux-x86_64'   => { triple: 'x86_64-linux-musl',  libs: %w[-lm],          ext: ''     },
  'linux-arm64'    => { triple: 'aarch64-linux-musl', libs: %w[-lm],          ext: ''     },
  'windows-x86_64' => { triple: 'x86_64-windows-gnu', libs: %w[-lws2_32 -lm], ext: '.exe' },
}

CLEAN.include(BUILD_XC)
CLOBBER.include(DIST)

def require_src!
  ENV['SRC'] or abort('SRC=path/to/program.rb is required')
end

def c_path_for(src_path)
  File.join(BUILD_XC, "#{File.basename(src_path, '.rb')}.c")
end

# Emit C, caching by mtime so multi-target runs only generate once.
def ensure_c(src_path)
  c_path = c_path_for(src_path)
  if !File.exist?(c_path) || File.mtime(c_path) < File.mtime(src_path)
    mkdir_p File.dirname(c_path)
    sh File.join(SPINEL_DIR, 'spinel'), src_path, '-c', '-o', c_path
  end
  c_path
end

# Bigint / regexp are linked from .c sources because the prebuilt
# libspinel_rt.a is host-arch only. Detect usage by scanning the .c.
def runtime_sources(c_path)
  body = File.read(c_path)
  srcs = []
  if body.include?('re_compile') || body.include?('re_exec')
    srcs.concat(Dir.glob(File.join(SPINEL_DIR, 'lib/regexp/*.c')))
  end
  srcs << File.join(SPINEL_DIR, 'lib/sp_bigint.c') if body.include?('sp_bigint_')
  srcs
end

def cross_compile(name, src_path)
  conf   = TARGETS.fetch(name)
  c_path = ensure_c(src_path)
  bn     = File.basename(src_path, '.rb')
  out    = File.join(DIST, "#{bn}-#{name}#{conf[:ext]}")
  mkdir_p DIST
  cmd = [
    *CC,
    '-target', conf[:triple],
    "-I#{SPINEL_DIR}/lib", "-I#{SPINEL_DIR}/lib/regexp",
    '-Os', '-s',
    c_path,
    *runtime_sources(c_path),
    *conf[:libs],
    '-o', out,
  ]
  sh(*cmd)
  printf "  -> %s (%d bytes)\n", out, File.size(out)
end

namespace :xc do
  TARGETS.each do |name, conf|
    desc "Cross-compile SRC=*.rb to #{name} (#{conf[:triple]})"
    task name do
      cross_compile(name, require_src!)
    end
  end

  desc 'List supported targets'
  task :targets do
    TARGETS.each { |n, c| printf "  %-16s %s\n", n, c[:triple] }
  end
end

desc 'Cross-compile SRC=*.rb to all targets'
task xc: TARGETS.keys.map { |n| "xc:#{n}" }

desc 'Native build for the host via ./spinel (Darwin/Linux/etc.)'
task :host do
  src = require_src!
  bn  = File.basename(src, '.rb')
  os  = `uname -s`.strip.downcase
  os_tag = os == 'darwin' ? 'macos' : os
  arch = `uname -m`.strip == 'arm64' ? 'arm64' : 'x86_64'
  out = File.join(DIST, "#{bn}-#{os_tag}-#{arch}")
  mkdir_p DIST
  sh File.join(SPINEL_DIR, 'spinel'), src, '-o', out
  printf "  -> %s (%d bytes)\n", out, File.size(out)
end

desc 'Build for host + every cross target'
task all: [:host, :xc]

namespace :docker do
  # Pick the Linux target matching the docker default arch on the host.
  def docker_linux_target
    arch = `uname -m`.strip
    case arch
    when 'arm64', 'aarch64' then 'linux-arm64'
    else 'linux-x86_64'
    end
  end

  desc 'Cross-compile SRC and run it inside a fresh Alpine container'
  task :smoke do
    src = require_src!
    target = ENV['DOCKER_TARGET'] || docker_linux_target
    cross_compile(target, src)
    bn = File.basename(src, '.rb')
    bin = File.join(DIST, "#{bn}-#{target}")
    tag = "spinel-smoke-#{bn}:latest"
    sh 'docker', 'build',
       '-t', tag,
       '-f', File.join(SPINEL_DIR, 'examples', 'Dockerfile'),
       '--build-arg', "BIN=#{bin.sub(SPINEL_DIR + '/', '')}",
       SPINEL_DIR
    sh 'docker', 'run', '--rm', tag
  end
end

task default: 'xc:targets'
