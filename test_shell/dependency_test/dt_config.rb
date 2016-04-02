Shelldon.shell :test do
  config do
    config_file '.shelldon_config'

    param :debug_mode do
      type :boolean
      default false
      opt 'd'
    end

    param :'-o' do
      type :string
      default 'emacs'
      adjust { |s| s.to_s.downcase.strip.gsub('vim', 'vi') }
      validate do |s|
        return false unless s == 'emacs' || s == 'vi'
        if s == 'emacs'
          Readline.emacs_editing_mode; true
        else
          Readline.vi_editing_mode; true
        end
      end
    end
  end
end
