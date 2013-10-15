module CodeClimate
  module TestReporter
    class Git

      class << self
        def info
          {
            head:         `git log -1 --pretty=format:'%H'`,
            committed_at: committed_at,
            branch:       branch_from_git,
          }
        end

        def branch_from_git_or_ci
          git_branch = branch_from_git
          ci_branch = Ci.service_data[:branch]

          if ci_branch.to_s.strip.size > 0
            ci_branch.sub(/^origin\//, "")
          elsif git_branch.to_s.strip.size > 0 && !git_branch.to_s.strip.start_with?("(")
            git_branch.sub(/^origin\//, "")
          else
            "master"
          end
        end

        private

        def committed_at
          committed_at = `git log -1 --pretty=format:'%ct'`
          committed_at.to_i.zero? ? nil : committed_at.to_i
        end

        def branch_from_git
          branch = `git branch`.split("\n").delete_if { |i| i[0] != "*" }
          branch = [branch].flatten.first
          branch ? branch.gsub("* ","") : nil
        end
      end
    end
  end
end
