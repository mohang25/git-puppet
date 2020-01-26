require 'spec_helper'
describe 'newftp' do
  context 'with default values for all parameters' do
    it { should contain_class('newftp') }
  end
end
