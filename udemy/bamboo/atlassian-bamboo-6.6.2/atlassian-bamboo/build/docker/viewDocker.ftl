[@s.textfield
        id='dockerImage'
        name='dockerImage'
        labelKey='build.isolation.docker.image.name'
        required=true/]

[#if create == true]
[#else]
[#-- @ftlvariable name="dataVolumes" type="java.util.List<com.atlassian.bamboo.docker.DataVolume>" --]
    [@ui.bambooSection id='volumesSection' titleKey='build.isolation.docker.volumes.header' collapsible=true isCollapsed=!(dataVolumes?has_content)]
        <div class="description full-size">[@s.text name='build.isolation.docker.volumes.description' /]</div>
        <div class="docker-pipelines__volumes"></div>

        <script type="text/javascript">
            require(['feature/docker-volume'], function (DockerVolume) {
                new DockerVolume({
                    el: '.docker-pipelines__volumes',
                    volumeMappings: [
                        [#list dataVolumes as dataVolume]
                            {
                                hostDirectory: '${dataVolume.hostDirectory?js_string}',
                                containerDirectory: '${dataVolume.containerDirectory?js_string}'
                            },
                        [/#list]
                    ],
                }).render();
            });
        </script>
    [/@ui.bambooSection]
[/#if]
