#!/usr/bin/env rake

class ReleaseTask
  include Ans::Releaser::GemTask

  def gem_host
    "gem.ans-web.co.jp"
  end
  def gem_root
    "/var/www/gems/public"
  end
end

ReleaseTask.new.build_release_tasks
