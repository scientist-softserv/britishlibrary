# Azure SMB mounts do not allow file permissions
FileUtils::Entry_.class_eval do
  def copy_metadata(path)
    st = lstat()
    if !st.symlink?
      begin
        File.utime st.atime, st.mtime, path
      rescue Errno::EPERM
      end
    end
    mode = st.mode
    begin
      if st.symlink?
        begin
          File.lchown st.uid, st.gid, path
        rescue NotImplementedError
        end
      else
        File.chown st.uid, st.gid, path
      end
    rescue Errno::EPERM, Errno::EACCES
      # clear setuid/setgid
      mode &= 01777
    end
    if st.symlink?
      begin
        File.lchmod mode, path
      rescue NotImplementedError
      end
    else
      begin
        File.chmod mode, path
      rescue Errno::EPERM
      end
    end
  end
end
