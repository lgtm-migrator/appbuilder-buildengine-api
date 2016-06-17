<?php
namespace tests\unit\console\components;
use console\components\CopyToS3Operation;
use tests\unit\UnitTestBase;

use common\models\Build;

use tests\unit\fixtures\common\models\JobFixture;
use tests\unit\fixtures\common\models\BuildFixture;
use tests\mock\s3client\MockS3Client;

class CopyToS3OperationTest extends UnitTestBase
{
    /**
     * @var \UnitTester
     */

    protected function _before()
    {
    }

    protected function _after()
    {
    }
    public function fixtures()
    {
        return [
            'job' => JobFixture::className(),
            'build' => BuildFixture::className(),
        ];
    }

    public function testPerformAction()
    {
        $this->setContainerObjects();
        $buildNumber = 11;
        MockS3Client::clearGlobals();
        $copyOperation = new CopyToS3Operation($buildNumber);
        $copyOperation->performOperation();
        $build = Build::findOne(['id' => 11]);
        $this->assertEquals(42, $build->version_code, " *** Version code should be set to 42");
        $expectedBase = "https://s3-us-west-2.amazonaws.com/sil-appbuilder-artifacts/testing/jobs/build_scriptureappbuilder_22/1/";
        $expectedFiles = "about.txt,Kuna_Gospels-1.0.apk,version_code.txt,play-listing/index.html";
        $this->assertEquals($expectedBase, $build->artifact_url_base, " *** Incorrect Artifact Url Base");
        $this->assertEquals($expectedFiles, $build->artifact_files, " *** Incorrect Artifact Files");
        $this->assertEquals(16, count(MockS3Client::$puts), " *** Wrong number of files");
        $expected = "testing/jobs/build_scriptureappbuilder_22/1/play-listing.html";
        $testParms = MockS3Client::$puts[14];
        $this->assertEquals($expected, $testParms['Key'], " *** Wrong file name");
        $expected = "text/html";
        $this->assertEquals($expected, $testParms['ContentType'], " *** Wrong Mime Type");
    }
}

