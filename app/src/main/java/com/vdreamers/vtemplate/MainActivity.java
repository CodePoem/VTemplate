/*
 * Copyright 2019 CodePoem LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.vdreamers.vtemplate;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView tvJenkinsBuildNumber = findViewById(R.id.tv_jenkins_build_number);
        tvJenkinsBuildNumber.setText(BuildConfig.JENKINS_BUILD_NUMBER);

        TextView tvJenkinsBuildUrl = findViewById(R.id.tv_jenkins_build_url);
        tvJenkinsBuildUrl.setText(BuildConfig.JENKINS_BUILD_URL);
    }
}
