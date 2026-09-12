import 'package:flutter/material.dart';

class CustomerNameScreen extends StatefulWidget {
  final String phone;

  const CustomerNameScreen({
    super.key,
    required this.phone,
  });

  @override
  State<CustomerNameScreen> createState() =>
      _CustomerNameScreenState();
}

class _CustomerNameScreenState
    extends State<CustomerNameScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;

  // =====================================================
  // NAME VALIDATION
  // =====================================================

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name';
    }

    if (name.length < 3) {
      return 'Please enter a valid name';
    }

    return null;
  }

  // =====================================================
  // CONTINUE
  // =====================================================

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    final name =
        _nameController.text.trim();

    Navigator.of(context).pop(name);
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F7F3),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF9F7F3),
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF171717),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =========================================
                // ICON
                // =========================================

                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color:
                        const Color(
                      0xFFFFE6D5,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color:
                        Color(0xFFEE7424),
                    size: 28,
                  ),
                ),

                const SizedBox(height: 26),

                // =========================================
                // TITLE
                // =========================================

                const Text(
                  'What’s your name?',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'We’ll use your name for your Qebox account and orders.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color:
                        Color(0xFF777777),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================================
                // NAME LABEL
                // =========================================

                const Text(
                  'Full name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 9),

                // =========================================
                // NAME FIELD
                // =========================================

                TextFormField(
                  controller:
                      _nameController,

                  keyboardType:
                      TextInputType.name,

                  textCapitalization:
                      TextCapitalization.words,

                  textInputAction:
                      TextInputAction.done,

                  validator:
                      _validateName,

                  onFieldSubmitted: (_) {
                    _continue();
                  },

                  decoration:
                      InputDecoration(
                    hintText:
                        'Enter your full name',

                    filled: true,

                    fillColor:
                        Colors.white,

                    prefixIcon:
                        const Icon(
                      Icons.person_outline,
                      color:
                          Color(
                        0xFF777777,
                      ),
                    ),

                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(
                          0xFFE8E5E0,
                        ),
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(
                          0xFFEE7424,
                        ),
                        width: 1.5,
                      ),
                    ),

                    errorBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(
                          0xFFE53935,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================
                // PHONE INFO
                // =========================================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .verified_outlined,
                        color:
                            Color(
                          0xFF2E7D32,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'Verified mobile number',
                              style:
                                  TextStyle(
                                fontSize:
                                    10,
                                color:
                                    Color(
                                  0xFF777777,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              widget.phone,
                              style:
                                  const TextStyle(
                                fontSize:
                                    13,
                                fontWeight:
                                    FontWeight
                                        .w700,
                                color:
                                    Color(
                                  0xFF171717,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // =========================================
                // CONTINUE BUTTON
                // =========================================

                SizedBox(
                  width:
                      double.infinity,
                  height: 56,
                  child:
                      ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _continue,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF171717,
                      ),

                      foregroundColor:
                          Colors.white,

                      disabledBackgroundColor:
                          const Color(
                        0xFF999999,
                      ),

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                    ),

                    child:
                        _isLoading
                            ? const SizedBox(
                                width:
                                    22,
                                height:
                                    22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style:
                                    TextStyle(
                                  fontSize:
                                      15,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}