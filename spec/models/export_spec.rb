require 'spec_helper'

describe Export do
  let(:committer) { create(:user, token: '123456') }
  let(:haskell) { create(:haskell) }
  let!(:exercise_1) { create(:exercise, guide: guide,
                             title: 'foo', original_id: 100, position: 1,
                             locale: 'en', tag_list: %w(foo bar),
                             language: haskell,
                             expectations: [Expectation.new(binding: 'bar', inspection: 'HasBinding')]) }
  let!(:exercise_2) { create(:exercise, guide: guide,
                             description: 'a description',
                             title: 'bar', tag_list: %w(baz bar), original_id: 200, position: 2,
                             language: haskell, test: 'foo bar') }
  let(:guide) { create(:guide, description: 'Baz', github_repository: 'flbulgarelli/never-existent-repo', language: haskell, locale: 'en') }
  let(:export) { guide.exports.create!(committer: committer) }


  describe '#status' do
    it { expect(export.status).to eq 'pending' }
  end

  describe 'write methods' do
    let(:dir) { 'spec/data/export' }

    before { Dir.mkdir(dir) }
    after { FileUtils.rm_rf(dir) }

    describe '#write_meta' do
      before { export.write_meta! dir }

      it { expect(File.exist? 'spec/data/export/meta.yml').to be true }
      it { expect(File.read 'spec/data/export/meta.yml').to eq "---\nlocale: en\nlanguage: Haskell\noriginal_id_format: '%05d'\norder:\n- 100\n- 200\n" }
    end

    describe '#write_description' do
      before { export.write_description! dir }
      it { expect(File.exist? 'spec/data/export/description.md').to be true }
      it { expect(File.read 'spec/data/export/description.md').to eq 'Baz' }
    end


    describe '#write_exercise' do
      context 'with expectations' do
        before { export.write_exercise! dir, exercise_1 }

        it { expect(File.exist? 'spec/data/export/00100_foo/expectations.yml').to be true }
        it { expect(File.read 'spec/data/export/00100_foo/expectations.yml').to eq "---\nexpectations:\n- binding: bar\n  inspection: HasBinding\n"}
      end

      context 'without expectations' do
        before { export.write_exercise! dir, exercise_2 }

        it { expect(Dir.exist? 'spec/data/export/00200_bar/').to be true }

        it { expect(File.exist? 'spec/data/export/00200_bar/description.md').to be true }
        it { expect(File.read 'spec/data/export/00200_bar/description.md').to eq 'a description' }

        it { expect(File.exist? 'spec/data/export/00200_bar/meta.yml').to be true }
        it { expect(File.read 'spec/data/export/00200_bar/meta.yml').to eq "---\ntags:\n- baz\n- bar\nlocale: :en\n"}


        it { expect(File.exist? 'spec/data/export/00200_bar/test.hs').to be true }
        it { expect(File.read 'spec/data/export/00200_bar/test.hs').to eq 'foo bar' }

        it { expect(File.exist? 'spec/data/export/00200_bar/expectations.yml').to be false }
      end
    end


    describe '#write_guide_files' do
      before { export.write_guide! dir }

      it { expect(Dir.exist? 'spec/data/export/').to be true }
      it { expect(Dir.exist? 'spec/data/export/00100_foo/').to be true }
      it { expect(Dir.exist? 'spec/data/export/00200_bar/').to be true }
      it { expect(File.exist? 'spec/data/export/description.md').to be true }
      it { expect(Dir['spec/data/export/*'].size).to eq 4 }
    end
  end

  describe '#run_export!' do
    context 'bad credentials' do
      before do
        begin
          export.run_export!
        rescue
        end
      end

      it do
        expect(export.status).to eq 'failed'
        expect(export.result).to include 'Bad credentials'
      end
    end
  end

end
