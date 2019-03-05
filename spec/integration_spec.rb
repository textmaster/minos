require 'spec_helper'

describe 'minos cli' do

  context 'when dockerfile is valid' do

    it do
      r = Minos::CLI.start(%w(build --manifest ./examples/minos.yaml))
      expect(r.all?(&:success?)).to be true
      r = Minos::CLI.start(%w(push --manifest ./examples/minos.yaml))
      expect(r.all?(&:success?)).to be true
    end

  end

  context 'when dockerfile is not valid' do

    it do
      r = Minos::CLI.start(%w(build --manifest ./examples/minos.invalid.yaml))
      expect(r.all?(&:success?)).to be false
    end

  end

end
