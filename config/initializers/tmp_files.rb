# Hardcode tmp file directory because of file permissions issues in prod envs
class Dir
  def self.tmpdir
    "/app/samvera/hyrax-webapp/tmp/shared"
  end
end
