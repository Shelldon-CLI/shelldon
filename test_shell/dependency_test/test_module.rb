Shelldon.module :test_module do
  command :harpdarp do
    action { puts 'HARPDARP' }
  end

  config do
    param :harpdarp do
      type :string
      default 'sweg'
    end
  end

  shell do
    prompt 'prompt!> '
  end
end
