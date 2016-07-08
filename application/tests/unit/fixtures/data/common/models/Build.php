<?php

use common\helpers\Utils;

return [
    'build1' => [
        'id' => 11,
        'job_id' => 22,
        'status' => 'completed',
        'build_number' => 1,
        'result' => 'SUCCESS',
        'error' => NULL,
        'artifact_url_base' => NULL,
        'artifact_files' => NULL,
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 1,
    ],
    'build2' => [
        'id' => 12,
        'job_id' => 22,
        'status' => 'completed',
        'build_number' => 1,
        'result' => 'SUCCESS',
        'error' => NULL,
        'artifact_url_base' => 'https://s3-us-west-2.amazonaws.com/sil-appbuilder-artifacts/testing/jobs/build_scriptureappbuilder_22/1/',
        'artifact_files' => 'Test-1.0.apk',
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 2,
    ],
    'build3' => [
        'id' => 13,
        'job_id' => 22,
        'status' => 'initialized',
        'build_number' => NULL,
        'result' => NULL,
        'error' => NULL,
        'artifact_url_base' => NULL,
        'artifact_files' => NULL,
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => NULL,
    ],
    'build4' => [
        'id' => 14,
        'job_id' => 22,
        'status' => 'active',
        'build_number' => 2,
        'result' => NULL,
        'error' => NULL,
        'artifact_url_base' => NULL,
        'artifact_files' => NULL,
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 3,
    ],
    'build5' => [
        'id' => 15,
        'job_id' => 23,
        'status' => 'active',
        'build_number' => 3,
        'result' => NULL,
        'error' => NULL,
       'artifact_url_base' => NULL,
       'artifact_files' => NULL,
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 4,
    ],
    'build6' => [
        'id' => 16,
        'job_id' => 24,
        'status' => 'active',
        'build_number' => 4,
        'result' => NULL,
        'error' => NULL,
        'artifact_url_base' => NULL,
        'artifact_files' => NULL,
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 5,
    ],
    'build7' => [
        'id' => 17,
        'job_id' => 22,
        'status' => 'completed',
        'build_number' => 1,
        'result' => 'FAILURE',
        'error' => NULL,
        'artifact_url_base' => NULL,
        'artifact_files' => NULL,
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 1,
    ],
    'build8' => [
        'id' => 18,
        'job_id' => 25,
        'status' => 'completed',
        'build_number' => 20,
        'result' => 'SUCCESS',
        'error' => NULL,
        'artifact_url_base' => 'https://s3-us-west-2.amazonaws.com/sil-appbuilder-artifacts/testing/jobs/build_scriptureappbuilder_22/1/',
        'artifact_files' => 'Test-1.0.apk',
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 2,
    ],
    'build9' => [
        'id' => 19,
        'job_id' => 25,
        'status' => 'completed',
        'build_number' => 21,
        'result' => 'SUCCESS',
        'error' => NULL,
        'artifact_url_base' => 'https://s3-us-west-2.amazonaws.com/sil-appbuilder-artifacts/testing/jobs/build_scriptureappbuilder_22/1/',
        'artifact_files' => 'about.txt,package_name.txt,Test-1.0.apk,version_code.txt,play-listing/index.html',
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 3,
    ],
    'build10' => [
        'id' => 20,
        'job_id' => 25,
        'status' => 'completed',
        'build_number' => 22,
        'result' => 'SUCCESS',
        'error' => NULL,
        'artifact_url_base' => 'https://s3-us-west-2.amazonaws.com/sil-appbuilder-artifacts/testing/jobs/build_scriptureappbuilder_22/1/',
        'artifact_files' => 'Test-1.0.apk',
        'created' => Utils::getDatetime(),
        'updated' => Utils::getDatetime(),
        'channel' => 'unpublished',
        'version_code' => 4,
    ],
];

